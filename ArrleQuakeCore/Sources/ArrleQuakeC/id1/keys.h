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

//
// these are the key numbers that should be passed to Key_Event
//
#define	K_TAB			0x2B
#define	K_ENTER			0x28
#define	K_ESCAPE		0x29
#define	K_SPACE			0x2C

// normal keys should be passed as lowercased ascii

#define	K_BACKSPACE		0x2A

#define	K_UPARROW		0x52
#define	K_DOWNARROW		0x51
#define	K_LEFTARROW		0x50
#define	K_RIGHTARROW	0x4F

#define	K_ALT			0xE2
#define	K_CTRL			0xE0
#define	K_SHIFT			0xE1
#define	K_F1			0x1E
#define	K_F2			0x1F
#define	K_F3			0x20
#define	K_F4			0x21
#define	K_F5			0x22
#define	K_F6			0x23
#define	K_F7			0x24
#define	K_F8			0x25
#define	K_F9			0x26
#define	K_F10			0x27
#define	K_F11			0x2D
#define	K_F12			0x2E
#define	K_INS			0
#define	K_DEL			0
#define	K_PGDN			0
#define	K_PGUP			0
#define	K_HOME			0
#define	K_END			0

#define K_PAUSE			0

//
// mouse buttons generate virtual keys
//
#define	K_MOUSE1		200
#define	K_MOUSE2		201
#define	K_MOUSE3		202

//
// joystick buttons
//
#define	K_JOY1			203
#define	K_JOY2			204
#define	K_JOY3			205
#define	K_JOY4			206

//
// aux keys are for multi-buttoned joysticks to generate so they can use
// the normal binding process
//
#define	K_AUX1			207
#define	K_AUX2			208
#define	K_AUX3			209
#define	K_AUX4			210
#define	K_AUX5			211
#define	K_AUX6			212
#define	K_AUX7			213
#define	K_AUX8			214
#define	K_AUX9			215
#define	K_AUX10			216
#define	K_AUX11			217
#define	K_AUX12			218
#define	K_AUX13			219
#define	K_AUX14			220
#define	K_AUX15			221
#define	K_AUX16			222
#define	K_AUX17			223
#define	K_AUX18			224
#define	K_AUX19			225
#define	K_AUX20			226
#define	K_AUX21			227
#define	K_AUX22			228
#define	K_AUX23			229
#define	K_AUX24			230
#define	K_AUX25			231
#define	K_AUX26			232
#define	K_AUX27			233
#define	K_AUX28			234
#define	K_AUX29			235
#define	K_AUX30			236
#define	K_AUX31			237
#define	K_AUX32			238

// JACK: Intellimouse(c) Mouse Wheel Support

#define K_MWHEELUP		239
#define K_MWHEELDOWN	240



typedef enum {key_game, key_console, key_message, key_menu} keydest_t;

extern keydest_t	key_dest;
extern char *keybindings[256];
extern	int		key_repeats[256];
extern	int		key_count;			// incremented every key event
extern	int		key_lastpress;

void Key_Event (int key, int down);
void Key_Init (void);
void Key_WriteBindings (FILE *f);
void Key_SetBinding (int keynum, char *binding);
void Key_ClearStates (void);

