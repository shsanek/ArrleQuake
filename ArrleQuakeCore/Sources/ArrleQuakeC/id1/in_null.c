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
// in_null.c -- for systems without a mouse

#include "quakedef.h"

float g_control_rotate_x = 0, g_control_rotate_y = 0;
float g_control_move_x = 0, g_control_move_y = 0;

void IN_Init (void)
{
}

void IN_Shutdown (void)
{
}

void IN_Commands (void)
{
}

void IN_Move (usercmd_t *cmd)
{
    cmd->forwardmove += cl_forwardspeed.value * g_control_move_y * cl_movespeedkey.value;
    cmd->sidemove += cl_forwardspeed.value * g_control_move_x * cl_movespeedkey.value;

    float speed = host_frametime * cl_anglespeedkey.value;

    cl.viewangles[YAW] -= speed * cl_yawspeed.value * g_control_rotate_x;
    cl.viewangles[YAW] = anglemod(cl.viewangles[YAW]);

    V_StopPitchDrift ();
    cl.viewangles[PITCH] -= speed * cl_pitchspeed.value * g_control_rotate_y;

    if (cl.viewangles[PITCH] > 80)
        cl.viewangles[PITCH] = 80;
    if (cl.viewangles[PITCH] < -70)
        cl.viewangles[PITCH] = -70;

    //    cmd->upmove -= cl_upspeed.value * CL_KeyState (&in_down);
//    if (cls.signon != SIGNONS)
//        return;
//
//    CL_AdjustAngles ();
//
//    Q_memset (cmd, 0, sizeof(*cmd));
//
//    if (in_strafe.state & 1)
//    {
//        cmd->sidemove += cl_sidespeed.value * CL_KeyState (&in_right);
//        cmd->sidemove -= cl_sidespeed.value * CL_KeyState (&in_left);
//    }
//
//    cmd->sidemove += cl_sidespeed.value * CL_KeyState (&in_moveright);
//    cmd->sidemove -= cl_sidespeed.value * CL_KeyState (&in_moveleft);
//
//    cmd->upmove += cl_upspeed.value * CL_KeyState (&in_up);
//    cmd->upmove -= cl_upspeed.value * CL_KeyState (&in_down);
//
//    if (! (in_klook.state & 1) )
//    {
//
//    }

//
// adjust for speed key
//
//    if (in_speed.state & 1)
//    {
//        cmd->forwardmove *= cl_movespeedkey.value;
//        cmd->sidemove *= cl_movespeedkey.value;
//        cmd->upmove *= cl_movespeedkey.value;
//    }
}

