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

#endif /* Render_h */
