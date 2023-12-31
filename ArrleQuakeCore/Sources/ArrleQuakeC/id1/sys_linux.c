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
#include <unistd.h>
#include <signal.h>
#include <stdlib.h>
#include <limits.h>
#include <sys/time.h>
#include <sys/types.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdarg.h>
#include <stdio.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <sys/stat.h>
#include <string.h>
#include <ctype.h>
#include <sys/wait.h>
#include <sys/mman.h>
#include <errno.h>
#include "DEFINE.h"
#include "quakedef.h"
#include "../Custom/CustomMalloc.h"

int noconinput = 0;
int nostdout = 0;

char *basedir = ".";
char *cachedir = "/tmp";

cvar_t  sys_linerefresh = {"sys_linerefresh","0"};// set for entity display

// =======================================================================
// General routines
// =======================================================================

void Sys_DebugNumber(int y, int val)
{
}

/*
void Sys_Printf (char *fmt, ...)
{
    va_list        argptr;
    char        text[1024];

    va_start (argptr,fmt);
    vsprintf (text,fmt,argptr);
    va_end (argptr);
    fprintf(stderr, "%s", text);

    Con_Print (text);
}

void Sys_Printf (char *fmt, ...)
{

    va_list     argptr;
    char        text[1024], *t_p;
    int         l, r;

    if (nostdout)
        return;

    va_start (argptr,fmt);
    vsprintf (text,fmt,argptr);
    va_end (argptr);

    l = strlen(text);
    t_p = text;

// make sure everything goes through, even though we are non-blocking
    while (l)
    {
        r = write (1, text, l);
        if (r != l)
            sleep (0);
        if (r > 0)
        {
            t_p += r;
            l -= r;
        }
    }

}
*/

void Sys_Printf (char *fmt, ...)
{
    va_list        argptr;
    char        text[2048];
    unsigned char        *p;

    va_start (argptr,fmt);
    vsprintf (text,fmt,argptr);
    va_end (argptr);

    if (strlen(text) > sizeof(text))
        Sys_Error("memory overwrite in Sys_Printf");

    if (nostdout)
        return;

    for (p = (unsigned char *)text; *p; p++)
        if ((*p > 128 || *p < 32) && *p != 10 && *p != 13 && *p != 9)
            printf("[%02x]", *p);
        else
            putc(*p, stdout);
}

void Sys_Quit (void)
{
    Host_Shutdown();
    fcntl (0, F_SETFL, fcntl (0, F_GETFL, 0) & ~FNDELAY);
    exit(0);
}

void Sys_Init(void)
{
#if id386
    Sys_SetFPCW();
#endif
}

void Sys_Error (char *error, ...)
{
    va_list     argptr;
    char        string[1024];

// change stdin to non blocking
    fcntl (0, F_SETFL, fcntl (0, F_GETFL, 0) & ~FNDELAY);

    va_start (argptr,error);
    vsprintf (string,error,argptr);
    va_end (argptr);
    fprintf(stderr, "Error: %s\n", string);

    Host_Shutdown ();
    exit (1);

}

void Sys_Warn (char *warning, ...)
{
    va_list     argptr;
    char        string[1024];

    va_start (argptr,warning);
    vsprintf (string,warning,argptr);
    va_end (argptr);
    fprintf(stderr, "Warning: %s", string);
}

/*
============
Sys_FileTime

returns -1 if not present
============
*/
int    Sys_FileTime (char *path)
{
    FILE    *f;

    f = fopen(path, "rb");
    if (f)
    {
        fclose(f);
        return 1;
    }

    return -1;
}


void Sys_mkdir (char *path)
{
    mkdir (path, 0777);
}

int filelength (FILE *f)
{
    long             pos;
    long             end;

    pos = ftell (f);
    fseek (f, 0, SEEK_END);
    end = ftell (f);
    fseek (f, pos, SEEK_SET);

    return (int)end;
}

int Sys_FileOpenRead (char *path, FILE **handle)
{
    FILE* f = fopen(path, "rb");
    if (!f) {
        Sys_Warn ("Warning opening %s\n", path);
        handle = NULL;
        return -1;
    }
    *handle = f;
    return filelength(f);
}

FILE* Sys_FileOpenWrite (char *path)
{
    FILE* f = fopen(path, "wb");
    if (!f) {
        Sys_Warn ("Warning opening %s\n", path);
    }
    return f;
}

int Sys_FileWrite (FILE* file, void *src, int count)
{
    return (int)fwrite(src, count, 1, file);
}

void Sys_FileClose (FILE* file)
{
    fclose(file);
}

void Sys_FileSeek (FILE* file, int position)
{
    fseek(file, position, SEEK_SET);
}

int Sys_FileRead (FILE* file, void *dest, int count)
{
    return (int)fread(dest, count, 1, file);
}

void Sys_DebugLog(char *file, char *fmt, ...)
{
    va_list argptr;
    static char data[1024];
    int fd;

    va_start(argptr, fmt);
    vsprintf(data, fmt, argptr);
    va_end(argptr);
//    fd = open(file, O_WRONLY | O_BINARY | O_CREAT | O_APPEND, 0666);
    fd = open(file, O_WRONLY | O_CREAT | O_APPEND, 0666);
    write(fd, data, strlen(data));
    close(fd);
}

//void Sys_EditFile(char *filename)
//{
//
//    char cmd[256];
//    char *term;
//    char *editor;
//
//    term = getenv("TERM");
//    if (term && !strcmp(term, "xterm"))
//    {
//        editor = getenv("VISUAL");
//        if (!editor)
//            editor = getenv("EDITOR");
//        if (!editor)
//            editor = getenv("EDIT");
//        if (!editor)
//            editor = "vi";
//        sprintf(cmd, "xterm -e %s %s", editor, filename);
//        system(cmd);
//    }
//
//}

double Sys_FloatTime (void) {
    struct timeval tv;
    gettimeofday(&tv,NULL);
    double perciseTimeStamp = tv.tv_sec + tv.tv_usec * 0.000001;
    return perciseTimeStamp;
}

// =======================================================================
// Sleeps for microseconds
// =======================================================================

static volatile int oktogo;

void alarm_handler(int x)
{
    oktogo=1;
}

void Sys_LineRefresh(void)
{
}

void floating_point_exception_handler(int whatever)
{
//    Sys_Warn("floating point exception\n");
    signal(SIGFPE, floating_point_exception_handler);
}

char *Sys_ConsoleInput(void)
{
#if 0
    static char text[256];
    int     len;

    if (cls.state == ca_dedicated) {
        len = read (0, text, sizeof(text));
        if (len < 1)
            return NULL;
        text[len-1] = 0;    // rip off the /n and terminate

        return text;
    }
#endif
    return NULL;
}

#if !id386
void Sys_HighFPPrecision (void)
{
}

void Sys_LowFPPrecision (void)
{
}
#endif

int        skipframes;
double oldtime = 0;

void qInit (int c, char **v)
{

    quakeparms_t parms;
    int j;

//    static char cwd[1024];

//    signal(SIGFPE, floating_point_exception_handler);
    signal(SIGFPE, SIG_IGN);

    memset(&parms, 0, sizeof(parms));

    COM_InitArgv(c, v);
    parms.argc = com_argc;
    parms.argv = com_argv;

    parms.memsize = 16*1024*1024;

    j = COM_CheckParm("-mem");
    if (j)
        parms.memsize = (int) (Q_atof(com_argv[j+1]) * 1024 * 1024);

    init_memory();
    parms.membase = (void*)memory_container;

    parms.basedir = basedir;
// caching is disabled by default, use -cachedir to enable
//    parms.cachedir = cachedir;

    noconinput = COM_CheckParm("-noconinput");
    if (!noconinput)
        fcntl(0, F_SETFL, fcntl (0, F_GETFL, 0) | FNDELAY);

    if (COM_CheckParm("-nostdout"))
        nostdout = 1;

    Sys_Init();

#ifdef SERVER_ONLY
    cls.state = ca_dedicated;
#endif

    Host_Init(&parms);

    oldtime = Sys_FloatTime ();
}

void qLoop(void) {
    double newtime = Sys_FloatTime ();
    double time = newtime - oldtime;

    Host_Frame(time);
    oldtime = newtime;
}


/*
================
Sys_MakeCodeWriteable
================
*/
void Sys_MakeCodeWriteable (unsigned long startaddr, unsigned long length)
{

    int r;
    unsigned long addr;
    int psize = getpagesize();

    addr = (startaddr & ~(psize-1)) - psize;

//    fprintf(stderr, "writable code %lx(%lx)-%lx, length=%lx\n", startaddr,
//            addr, startaddr+length, length);

    r = mprotect((char*)addr, length + startaddr - addr + psize, 7);

    if (r < 0)
            Sys_Error("Protection change failed\n");

}
