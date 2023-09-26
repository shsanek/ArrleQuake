//
//  Render.h
//  GameTest
//
//  Created by Alex Shipin on 9/26/23.
//

#ifndef Render_h
#define Render_h

#import <CoreGraphics/CoreGraphics.h>

CGImageRef renderImage(void);
void qLoop(void);
void qInit (int c, char **v);
void VID_SetSize(int width, int height);
void Key_Event (int key, int down);

void Cbuf_AddText (const char *text);

extern float g_control_rotate_x, g_control_rotate_y;
extern float g_control_move_x, g_control_move_y;

#endif /* Render_h */
