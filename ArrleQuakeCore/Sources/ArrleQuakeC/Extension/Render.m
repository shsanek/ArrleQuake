#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

extern uint g_VidScreenWidth;
extern uint g_VidScreenHeight;
extern unsigned char* vid_buffer;
extern    unsigned*    d_8to24table;

char *g_pixelsData = NULL;
int gChannelCount = 4;
CGColorSpaceRef g_ColorSpaceRef = NULL;
CGContextRef g_Context = NULL;
int isRegenerateContext = 0;
uint widthSize = 0;

void regenerateContext(void)
{
    if (isRegenerateContext) {
        CGContextRelease(g_Context);
        free(g_pixelsData);
        isRegenerateContext = 0;
    }
    uint width = g_VidScreenWidth;
    uint height = g_VidScreenHeight;

    widthSize = width * gChannelCount;
    g_pixelsData = malloc(height * widthSize);
    if (!g_pixelsData) {
        return;
    }
    __auto_type g_ColorSpaceRef = CGColorSpaceCreateDeviceRGB();
    if (!g_ColorSpaceRef) {
        free(g_pixelsData);
        return;
    }

    g_Context = CGBitmapContextCreate(
                                      g_pixelsData,
                                      width,
                                      height,
                                      8,
                                      widthSize,
                                      g_ColorSpaceRef,
                                      kCGImageAlphaPremultipliedLast
                                      );
    if (g_Context) {
        isRegenerateContext = 1;
    }
}

CGImageRef g_Image = NULL;

int isRenderImage = 0;

CGImageRef renderImage(void) {
    if (!isRenderImage) {
        isRenderImage = 0;
    }

    if (!g_pixelsData) {
        return nil;
    }

    for (int y = 0; y < g_VidScreenHeight; y++) {
        for (int x = 0; x < g_VidScreenWidth; x++) {
            __auto_type index = vid_buffer[y * g_VidScreenWidth + x];
            memcpy(
                   g_pixelsData + y * widthSize + x * gChannelCount,
                   d_8to24table + index,
                   4
                   );
        }
    }

    g_Image = CGBitmapContextCreateImage(g_Context);


    if (!g_Image) {
        return nil;
    }

    return g_Image;
}
