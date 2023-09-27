// vid_null.c -- null video driver to aid porting efforts

#include "../id1/quakedef.h"
#include "../id1/d_local.h"
#include "../id1/DEFINE.h"
#include <math.h>

//viddef_t	vid;				// global video state

#define	BASEWIDTH	320
#define	BASEHEIGHT	200

byte* vid_buffer = NULL;
short* zbuffer = NULL;
byte* surfcache = NULL;

uint g_VidScreenWidth;
uint g_VidScreenHeight;


unsigned char g_QWPalette[256][3] = {};

unsigned short d_8to16table[256];
unsigned* d_8to24table = NULL;

void regenerateContext(void);

void VID_SetSize(int width, int height)
{
    D_FlushCaches();

    if (surfcache != NULL)
    {
        free(surfcache);
    }

    if (zbuffer != NULL)
    {
        free(zbuffer);
    }

    if (vid_buffer != NULL)
    {
        free(vid_buffer);
    }

    g_VidScreenWidth = width;

    if (g_VidScreenWidth < 320)
    {
        g_VidScreenWidth = 320;
    }

    if (g_VidScreenWidth > 1280)
    {
        g_VidScreenWidth = 1280;
    }

    g_VidScreenHeight = height;

    if (g_VidScreenHeight < 200)
    {
        g_VidScreenHeight = 200;
    }

    if (g_VidScreenHeight > 960)
    {
        g_VidScreenHeight = 960;
    }

    if (g_VidScreenHeight > g_VidScreenWidth)
    {
        g_VidScreenHeight = g_VidScreenWidth;
    }

    vid_buffer = malloc(g_VidScreenWidth * g_VidScreenHeight * sizeof(byte));

    zbuffer = malloc(g_VidScreenWidth * g_VidScreenHeight * sizeof(short));

    vid.width = vid.conwidth = g_VidScreenWidth;
    vid.height = vid.conheight = g_VidScreenHeight;
    vid.aspect = ((float)vid.height / (float)vid.width) * (320.0f / 240.0f);

    vid.buffer = vid.conbuffer = vid_buffer;
    vid.rowbytes = vid.conrowbytes = g_VidScreenWidth;

    d_pzbuffer = zbuffer;

    int surfcachesize = D_SurfaceCacheForRes(g_VidScreenWidth, g_VidScreenHeight);

    surfcache = malloc(surfcachesize);

    D_InitCaches (surfcache, surfcachesize);

    vid.recalc_refdef = 1;

#ifdef CLIENT
    regenerateContext();
#endif
}

#define COLOR(C) ( ((float)C) * (1.5f) / 255.0f )
#define COLOR_NORMALIZE(C) ((unsigned char)fmin(fmax(0, COLOR(C) * 255 ), 255))

void    VID_SetPalette (unsigned char *palette)
{
    byte    *pal;
    unsigned char r,g,b;
    unsigned v;
    unsigned short i;
    unsigned    *table;

    pal = palette;
    table = d_8to24table;
    for (i=0 ; i<256 ; i++)
    {
        r = COLOR_NORMALIZE(pal[0]);
        g = COLOR_NORMALIZE(pal[1]);
        b = COLOR_NORMALIZE(pal[2]);
        pal += 3;

        v = (255 << 24) | (b << 16) | (g << 8) | r;
        *table++ = v;
    }
    d_8to24table[255] &= 0xFFFFFF;    // 255 is transparent
}

void    VID_ShiftPalette (unsigned char *palette)
{
    VID_SetPalette(palette);
}

void    VID_Init (unsigned char *palette)
{
    vid_buffer = malloc(g_VidScreenWidth * g_VidScreenHeight * sizeof(byte));
    zbuffer = malloc(g_VidScreenWidth * g_VidScreenHeight * sizeof(short));
    d_8to24table = malloc(256 * sizeof(unsigned));

    vid.maxwarpwidth = WARP_WIDTH;
    vid.maxwarpheight = WARP_HEIGHT;
    vid.width = vid.conwidth = g_VidScreenWidth;
    vid.height = vid.conheight = g_VidScreenHeight;
    vid.aspect = ((float)vid.height / (float)vid.width) * (320.0 / 240.0);
    vid.numpages = 1;
    vid.colormap = host_colormap;
    vid.fullbright = 256 - LittleLong (*((int *)vid.colormap + 2048));
    vid.buffer = vid.conbuffer = vid_buffer;
    vid.rowbytes = vid.conrowbytes = g_VidScreenWidth;

    d_pzbuffer = zbuffer;

    int surfcachesize = D_SurfaceCacheForRes(g_VidScreenWidth, g_VidScreenHeight);

    surfcache = malloc(surfcachesize);

    D_InitCaches (surfcache, surfcachesize);

    VID_SetPalette(palette);
}

void    VID_Shutdown (void)
{
    if (surfcache != NULL)
    {
        free(surfcache);
    }

    if (d_8to24table != NULL)
    {
        free(d_8to24table);
    }

    if (zbuffer != NULL)
    {
        free(zbuffer);
    }

    if (vid_buffer != NULL)
    {
        free(vid_buffer);
    }
}

void    VID_Update (vrect_t *rects)
{
}

/*
 ================
 D_BeginDirectRect
 ================
 */
void D_BeginDirectRect (int x, int y, byte *pbitmap, int width, int height)
{
}


/*
 ================
 D_EndDirectRect
 ================
 */
void D_EndDirectRect (int x, int y, int width, int height)
{
}
