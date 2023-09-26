#include "../id1/quakedef.h"

qboolean        isDedicated = 1;

void CDAudio_Play(byte track, qboolean looping)
{
}

void CDAudio_Stop(void)
{
}


void CDAudio_Pause(void)
{
}


void CDAudio_Resume(void)
{
}


void CDAudio_Update(void)
{
}


int CDAudio_Init(void)
{
    return 0;
}


void CDAudio_Shutdown(void)
{
}

void CL_InitCam(void) {

}
qboolean Cam_DrawViewModel(void) {
    return 1;
}
qboolean Cam_DrawPlayer(int playernum) {
    return 1;
}
void Cam_Track(usercmd_t *cmd) {

}
void Cam_FinishMove(usercmd_t *cmd) {

}
void Cam_Reset(void) {
    
}


int SNDDMA_GetDMAPos(void) {
    return 1;
}
qboolean SNDDMA_Init(void) {
    return 1;
}
void SNDDMA_Shutdown(void) {

}
void SNDDMA_Submit(void) {

}

cvar_t        _windowed_mouse;
int        autocam = 0;
int spec_track = 0;

void Sys_SendKeyEvents (void)
{
}
