/*
Copyright (C) 1996-1997 Id Software, Inc.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  

See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

*/
// net_udp.c

#include "quakedef.h"
#include <sys/fcntl.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <sys/param.h>
#include <sys/ioctl.h>
#include <errno.h>
#include <unistd.h>
#include <arpa/inet.h>

#ifdef __sun__
#include <sys/filio.h>
#endif

#ifdef NeXT
#include <libc.h>
#endif

// extern int gethostname (char *, int);
// extern int close (int);

extern cvar_t hostname;

static int net_acceptsocket = -1;		// socket for fielding new connections
static int net_controlsocket;
static int net_broadcastsocket = 0;
static struct qsockaddr broadcastaddr;

static unsigned long myAddr;

fd_set socket_redy_fds;
fd_set socket_redy_edit_fds;

int UDP_OpenListenerSocket (int port);

#include "net_udp.h"

//=============================================================================

#define MAX_CONNECTION 10
#define PACK_BUFFER_SIZE (MAX_DATAGRAM)
struct NetPackContainer {
    char buff[PACK_BUFFER_SIZE*2];
    unsigned short fullSize;
    unsigned short currentSize;
    char index;
    char active;
    int sock;
};

struct NetPackContainer readNetPackContainer[MAX_CONNECTION];
char isReadNetPackContainerInited = 0;

void initReadNetPackContainer() {
    if (!isReadNetPackContainerInited) {
        for (int i = 0; i < MAX_CONNECTION; i++) {
            readNetPackContainer[i].sock = -1;
        }
        isReadNetPackContainerInited = 0;
    }
}

struct NetPackContainer* searchReadNetPackContainer(int sock) {
    return readNetPackContainer + sock;
}

int newReadNetPackContainer(int sock) {
    for (int i = 0; i < MAX_CONNECTION; i++) {
        if (readNetPackContainer[i].sock == -1) {
            readNetPackContainer[i].fullSize = 0;
            readNetPackContainer[i].currentSize = 0;
            readNetPackContainer[i].index = i;
            readNetPackContainer[i].active = 1;
            readNetPackContainer[i].sock = sock;
            printf("new socket i:%d, s:%d\n", i, sock);
            return i;
        }
    }
    return -1;
}


int _Pack_Load (struct NetPackContainer* pack);

#define GET_PACK \
GET_PACK_INDEX(socket)

#define GET_PACK_INDEX(index) \
struct NetPackContainer* pack = searchReadNetPackContainer(index);\
if (pack == NULL || pack->sock == -1) {\
    return -1;\
}\


//=============================================================================

int UDP_Init (void)
{
	struct hostent *local;
	char	buff[MAXHOSTNAMELEN];
	struct qsockaddr addr;
	char *colon;
	
    initReadNetPackContainer();
//    FD_ZERO(&socket_redy_fds);
//    FD_ZERO(&socket_redy_edit_fds);

	if (COM_CheckParm ("-noudp"))
		return -1;

	local = gethostbyname("127.0.0.1");
	myAddr = *(int *)local->h_addr_list[0];

	// if the quake hostname isn't set, set it to the machine name
	if (Q_strcmp(hostname.string, "UNNAMED") == 0)
	{
		buff[15] = 0;
		Cvar_Set ("hostname", buff);
	}

	if ((net_controlsocket = UDP_OpenListenerSocket (0)) == -1)
		Sys_Error("UDP_Init: Unable to open control socket\n");

	((struct sockaddr_in *)&broadcastaddr)->sin_family = AF_INET;
	((struct sockaddr_in *)&broadcastaddr)->sin_addr.s_addr = INADDR_BROADCAST;
	((struct sockaddr_in *)&broadcastaddr)->sin_port = htons(net_hostport);

	UDP_GetSocketAddr (net_controlsocket, &addr);
	Q_strcpy(my_tcpip_address,  UDP_AddrToString (&addr));
	colon = Q_strrchr (my_tcpip_address, ':');
	if (colon)
		*colon = 0;

	Con_Printf("UDP Initialized\n");
	tcpipAvailable = true;


	return net_controlsocket;
}

//=============================================================================

void UDP_Shutdown (void)
{
	UDP_Listen (false);
	UDP_CloseSocket (net_controlsocket);
}

//=============================================================================

void UDP_Listen (qboolean state)
{
	// enable listening
	if (state)
	{
		if (net_acceptsocket != -1)
			return;
		if ((net_acceptsocket = UDP_OpenListenerSocket (net_hostport)) == -1)
			Sys_Error ("UDP_Listen: Unable to open accept socket\n");
		return;
	}

	// disable listening
	if (net_acceptsocket == -1)
		return;
	UDP_CloseSocket (net_acceptsocket);
	net_acceptsocket = -1;
}

//=============================================================================

int UDP_OpenListenerSocket (int port)
{
    int newsocket;
    struct sockaddr_in address;
    qboolean _true = true;

    if ((newsocket = socket (PF_INET, SOCK_STREAM, IPPROTO_IP)) == -1)
        return -1;

    if (fcntl(newsocket, F_SETFL, O_NONBLOCK) == -1)
        goto ErrorReturn;

    address.sin_family = AF_INET;
    address.sin_addr.s_addr = INADDR_ANY;
    address.sin_port = htons(port);

    if( bind (newsocket, (void *)&address, sizeof(address)) == -1)
        goto ErrorReturn;

    if (listen(newsocket, 10) == -1) {
        goto ErrorReturn;
    }

    int returnSocket;
    if ((returnSocket = newReadNetPackContainer(newsocket)) == -1) {
        goto ErrorReturn;
    }
    // FD_SET(newsocket, &socket_redy_fds);

    return returnSocket;

ErrorReturn:
    close (newsocket);
    return -1;
}

int UDP_OpenSocket (int port)
{
	int newsocket;
	struct sockaddr_in address;
	qboolean _true = true;

	if ((newsocket = socket (PF_INET, SOCK_STREAM, IPPROTO_IP)) == -1)
		return -1;

    if (fcntl(newsocket, F_SETFL, O_NONBLOCK) == -1)
        goto ErrorReturn;

    int returnSocket;
    if ((returnSocket = newReadNetPackContainer(newsocket)) == -1) {
        goto ErrorReturn;
    }

    printf("create socket %d\n", newsocket);
    // FD_SET(newsocket, &socket_redy_fds);
	return returnSocket;

ErrorReturn:
	close (newsocket);
	return -1;
}

//=============================================================================

int UDP_CloseSocket (int socket)
{
	if (socket == net_broadcastsocket)
		net_broadcastsocket = 0;
    GET_PACK
    printf("close connect f %d\n", pack->sock);
    int ret = close (pack->sock);
    pack->sock = -1;
	return ret;
}


//=============================================================================
/*
============
PartialIPAddress

this lets you type only as much of the net address as required, using
the local network components to fill in the rest
============
*/
static int PartialIPAddress (char *in, struct qsockaddr *hostaddr)
{
	char buff[256];
	char *b;
	int addr;
	int num;
	int mask;
	int run;
	int port;
	
	buff[0] = '.';
	b = buff;
	strcpy(buff+1, in);
	if (buff[1] == '.')
		b++;

	addr = 0;
	mask=-1;
	while (*b == '.')
	{
		b++;
		num = 0;
		run = 0;
		while (!( *b < '0' || *b > '9'))
		{
		  num = num*10 + *b++ - '0';
		  if (++run > 3)
		  	return -1;
		}
		if ((*b < '0' || *b > '9') && *b != '.' && *b != ':' && *b != 0)
			return -1;
		if (num < 0 || num > 255)
			return -1;
		mask<<=8;
		addr = (addr<<8) + num;
	}
	
	if (*b++ == ':')
		port = Q_atoi(b);
	else
		port = net_hostport;

	hostaddr->sa_family = AF_INET;
	((struct sockaddr_in *)hostaddr)->sin_port = htons((short)port);	
	((struct sockaddr_in *)hostaddr)->sin_addr.s_addr = (myAddr & htonl(mask)) | htonl(addr);
	
	return 0;
}
//=============================================================================

int UDP_Connect (int socket, struct qsockaddr *addr)
{
    GET_PACK
    struct sockaddr_in s_addr;
    s_addr.sin_family = AF_INET;
    s_addr.sin_port = ((struct sockaddr_in *)addr)->sin_port;
    s_addr.sin_addr.s_addr = ((struct sockaddr_in *)addr)->sin_addr.s_addr;

    printf("try connect to %s\n", UDP_AddrToString((void*)&s_addr));
    int ret;
    for (int i = 0; i<5; i++) {
        int ret = connect(pack->sock, (struct sockaddr*)&s_addr, sizeof(s_addr));
        if (ret == -1 && errno != EINPROGRESS) {
            break;
        }
        if (ret >= 0) {
            break;
        }
        usleep(0.2 * 1000000.0);
    }

    if (errno == ECONNREFUSED) {
        close(pack->sock);
        pack->sock = -1;
        return -1;
    }

    if (ret == -1) {
        printf("connect error %d\n", errno);
        close(pack->sock);
        pack->sock = -1;
    }

	return ret;
}

//=============================================================================

int UDP_CheckNewConnections (void)
{
	unsigned long	available;
    GET_PACK_INDEX(net_acceptsocket);

    socket_redy_edit_fds = socket_redy_fds;

    int socket = accept (pack->sock, NULL, 0);

    if (socket != -1) {
        if (fcntl(socket, F_SETFL, O_NONBLOCK) == -1) {
            printf("error %d\n", errno);
        }
        printf("new connect %d\n", socket);
        int ret = 0;
        if ((ret = newReadNetPackContainer(socket)) == -1) {
            close(socket);
            printf("close connect a %d\n", socket);
        } else {
            readNetPackContainer[ret].active = 0;
//            FD_CLR(socket, &socket_redy_fds);
        }
    } else if (errno != EAGAIN) {
        printf("connection error %d\n", errno);
    }
    for (int i = 0; i < MAX_CONNECTION; i++) {
        struct NetPackContainer* pack = readNetPackContainer + i;
        if (pack->sock != -1 && pack->active == 0) {
            int ret = _Pack_Load(pack);
            if (ret > 0) {
                pack->active = 1;
                return pack->index;
            }
            if (ret == -1) {
                close(pack->sock);
                pack->sock = -1;
            }
        }
    }
    return -1;
}

//=============================================================================

int UDP_Read (int socket, byte *buf, int len, struct qsockaddr *addr)
{
    GET_PACK
    if (socket != pack->index) {
        return  -1;
    }
    int result = _Pack_Load(pack);
    if (result == -1) {
        return -1;
    }
    if (result == 0) {
        return 0;
    }
    int size = pack->fullSize-sizeof(unsigned short);
    if (size > 0) {
        memcpy(buf, pack->buff + sizeof(unsigned short), size);
    }
    pack->currentSize -= pack->fullSize;
    if (pack->currentSize > 0) {
        memcpy(pack->buff, pack->buff + pack->fullSize, pack->currentSize);
        if (pack->currentSize >= sizeof(unsigned short)) {
            pack->fullSize = *((unsigned short*)pack->buff);
        } else {
            pack->fullSize = 0;
        }
    } else {
        pack->fullSize = 0;
    }
	return size;
}


int _UDP_Read (struct NetPackContainer* pack, int len)
{
    int ret = 0;
    int pos = (pack->currentSize);
    ret = (int)recv (pack->sock, pack->buff + pos, len, 0);
    int error = errno;
    if (ret == -1 && (error == EWOULDBLOCK || error == ECONNREFUSED)) {
        return 0;
    }
    if (ret > 0) {
        pack->currentSize += ret;
    } else {
        if (error == ECONNRESET) {
            close(pack->sock);
            pack->sock = -1;
            printf("disconnect\n");
        }
    }
    return ret;
}

int _Pack_Load (struct NetPackContainer* pack)
{
    if (pack->fullSize == 0) {
        if (_UDP_Read(pack, MAX_DATAGRAM) == -1) {
            return -1;
        }
        if (pack->currentSize >= sizeof(unsigned short)) {
            pack->fullSize = *((unsigned short*)pack->buff);
        } else {
            return 0;
        }
    } else if (pack->fullSize <= pack->currentSize) {
        return pack->fullSize;
    } else {
        if (_UDP_Read(pack, (pack->fullSize - pack->currentSize)) == -1) {
            return -1;
        }
    }
    return (pack->fullSize <= pack->currentSize) ? pack->fullSize : 0;
}

//=============================================================================

int UDP_MakeSocketBroadcastCapable (int socket)
{
    GET_PACK
	int				i = 1;

	// make this socket broadcast capable
	if (setsockopt(pack->sock, SOL_SOCKET, SO_BROADCAST, (char *)&i, sizeof(i)) < 0)
		return -1;
	net_broadcastsocket = socket;

	return 0;
}

//=============================================================================

int UDP_Broadcast (int socket, byte *buf, int len)
{
	int ret;

	if (socket != net_broadcastsocket)
	{
		if (net_broadcastsocket != 0)
			Sys_Error("Attempted to use multiple broadcasts sockets\n");
		ret = UDP_MakeSocketBroadcastCapable (socket);
		if (ret == -1)
		{
			Con_Printf("Unable to make socket broadcast capable\n");
			return ret;
		}
	}

	return UDP_Write (socket, buf, len, &broadcastaddr);
}

//=============================================================================

unsigned char write_buffer[MAX_DATAGRAM + NET_HEADERSIZE + sizeof(unsigned short)];
int UDP_Write (int socket, byte *buf, int len, struct qsockaddr *addr)
{
    GET_PACK
    int ret;
    if (len != 0) {
        memcpy(write_buffer + sizeof(unsigned short), buf, len);
    }
    buf = write_buffer;
    int size = len + sizeof(unsigned short);
    *((unsigned short*)write_buffer) = size;
    char name[128] = "";
    UDP_GetNameFromAddr(addr, (char*)name);
    char* res = name ? name : "";
//    printf("try send to <%d> adr <%s> len <%d>\n", socket, res, len);
    while (size > 0) {
        ret = (int)send(pack->sock, buf, size, 0);
        if (ret == -1) {
            break;
        }
        buf += ret;
        size -= ret;
    }
    int error = errno;
//    printf("send ret <%d> %d\n", ret, error);
    if (ret == -1 && error == EWOULDBLOCK) {
        return 0;
    }
    if (ret == -1 && error == ECONNRESET) {
        close(pack->sock);
        pack->sock = -1;
        printf("disconnect\n");
    }
    return ret;
}

//=============================================================================

char *UDP_AddrToString (struct qsockaddr *addr)
{
	static char buffer[22];
	int haddr;

	haddr = ntohl(((struct sockaddr_in *)addr)->sin_addr.s_addr);
	sprintf(buffer, "%d.%d.%d.%d:%d", (haddr >> 24) & 0xff, (haddr >> 16) & 0xff, (haddr >> 8) & 0xff, haddr & 0xff, ntohs(((struct sockaddr_in *)addr)->sin_port));
	return buffer;
}

//=============================================================================

int UDP_StringToAddr (char *string, struct qsockaddr *addr)
{
	int ha1, ha2, ha3, ha4, hp;
	int ipaddr;

	sscanf(string, "%d.%d.%d.%d:%d", &ha1, &ha2, &ha3, &ha4, &hp);
	ipaddr = (ha1 << 24) | (ha2 << 16) | (ha3 << 8) | ha4;

	addr->sa_family = AF_INET;
	((struct sockaddr_in *)addr)->sin_addr.s_addr = htonl(ipaddr);
	((struct sockaddr_in *)addr)->sin_port = htons(hp);
	return 0;
}

//=============================================================================

int UDP_GetSocketAddr (int socket, struct qsockaddr *addr)
{
    GET_PACK
	int addrlen = sizeof(struct qsockaddr);
	unsigned int a;

	Q_memset(addr, 0, sizeof(struct qsockaddr));
	getsockname(pack->sock, (struct sockaddr *)addr, &addrlen);
	a = ((struct sockaddr_in *)addr)->sin_addr.s_addr;
	if (a == 0 || a == inet_addr("127.0.0.1"))
		((struct sockaddr_in *)addr)->sin_addr.s_addr = myAddr;

	return 0;
}

//=============================================================================

int UDP_GetNameFromAddr (struct qsockaddr *addr, char *name)
{
	struct hostent *hostentry;

	hostentry = gethostbyaddr ((char *)&((struct sockaddr_in *)addr)->sin_addr, sizeof(struct in_addr), AF_INET);
	if (hostentry)
	{
		Q_strncpy (name, (char *)hostentry->h_name, NET_NAMELEN - 1);
		return 0;
	}

	Q_strcpy (name, UDP_AddrToString (addr));
	return 0;
}

//=============================================================================

int UDP_GetAddrFromName(char *name, struct qsockaddr *addr)
{
	struct hostent *hostentry;

	if (name[0] >= '0' && name[0] <= '9')
		return PartialIPAddress (name, addr);
	
	hostentry = gethostbyname (name);
	if (!hostentry)
		return -1;

	addr->sa_family = AF_INET;
	((struct sockaddr_in *)addr)->sin_port = htons(net_hostport);	
	((struct sockaddr_in *)addr)->sin_addr.s_addr = *(int *)hostentry->h_addr_list[0];

	return 0;
}

//=============================================================================

int UDP_AddrCompare (struct qsockaddr *addr1, struct qsockaddr *addr2)
{
	if (addr1->sa_family != addr2->sa_family)
		return -1;

	if (((struct sockaddr_in *)addr1)->sin_addr.s_addr != ((struct sockaddr_in *)addr2)->sin_addr.s_addr)
		return -1;

	if (((struct sockaddr_in *)addr1)->sin_port != ((struct sockaddr_in *)addr2)->sin_port)
		return 1;

	return 0;
}

//=============================================================================

int UDP_GetSocketPort (struct qsockaddr *addr)
{
	return ntohs(((struct sockaddr_in *)addr)->sin_port);
}


int UDP_SetSocketPort (struct qsockaddr *addr, int port)
{
	((struct sockaddr_in *)addr)->sin_port = htons(port);
	return 0;
}

//=============================================================================
