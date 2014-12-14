; #########################################################################
;
;   rotate.inc - Includes for EECS205 Assignment 3
;
;
; #########################################################################

include blit.inc

BasicBlit PROTO STDCALL lpBmp:PTR EECS205BITMAP, xcenter:DWORD, ycenter:DWORD

RotateBlit PROTO STDCALL lpBmp:PTR EECS205BITMAP, xcenter:DWORD, ycenter:DWORD, angle:DWORD

RotateBlitA PROTO STDCALL lpBmp:PTR EECS205BITMAP, xcenter:DWORD, ycenter:DWORD, angle:DWORD

Bounce PROTO STDCALL lpBmp:PTR EECS205BITMAP, sprt:PTR SPRITE

MoveHoriz PROTO STDCALL sprt:PTR SPRITE, x_inc:DWORD

MoveVertical PROTO STDCALL proj: PTR SPRITE, y_inc:DWORD

ShootProj PROTO STDCALL proj:PTR SPRITE, shoot:DWORD, shooter:PTR SPRITE

Collision PROTO STDCALL proj:PTR SPRITE, objective: PTR SPRITE, explosionsprite:PTR SPRITE

CollisionDie PROTO STDCALL proj:PTR SPRITE, objective: PTR SPRITE

RotateBlitProj PROTO STDCALL lpBmp:PTR EECS205BITMAP, xcenter:DWORD, ycenter:DWORD, angle:DWORD, mySprite:PTR SPRITE

RandomNum PROTO STDCALL 

SlideDown PROTO STDCALL myobject:PTR SPRITE


EXTERNDEF hits:DWORD
EXTERNDEF ammo:DWORD
EXTERNDEF dead:DWORD
EXTERNDEF counterss:DWORD
EXTERNDEF randomvar:DWORD
EXTERNDEF count_explosion:DWORD