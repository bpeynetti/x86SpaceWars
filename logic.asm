; #########################################################################
;
;   logic.asm - Assembly file for EECS205 Assignment 4/5
;
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

    include stars.inc	
    include blit.inc
    include rotate.inc	
    include game.inc
    include keys.inc		
	
.DATA


.CODE
GameLogic PROC USES eax ebx ecx edx xinc:DWORD, yinc:DWORD, mouseStat:DWORD, shoot:DWORD
;handles sprite animation 

	;put x,y,and angle on coordinates of the clickStar SPRITE
	mov eax,mouseClick.x
	add eax,xinc
	mov mouseClick.x,eax
	mov clickStar.x,eax
	mov clickStar2.x,70
	
	mov ebx,mouseClick.y
	; add ebx,yinc
	mov clickStar.y,ebx
	mov clickStar2.y,70
	mov edx,angle
	mov clickStar.a,edx
	mov clickStar2.a,edx

	mov ecx,mouseStat
	and ecx,2h	;eliminate all except the left button
	cmp ecx,0
	jz mouse_no_click

mouse_no_click:
	INVOKE Bounce, OFFSET fighter_000, OFFSET bounceStar
	
	;INVOKE SlideDown, OFFSET baddie_1
	;INVOKE SlideDown, OFFSET baddie_2
	
	
	;dealing with shootingShip
	INVOKE SlideDown, OFFSET baddie_1
	INVOKE MoveHoriz, OFFSET shootingShip, xinc
	INVOKE MoveVertical, OFFSET shootingShip, yinc
	INVOKE ShootProj, OFFSET projectile, shoot, OFFSET shootingShip	
	INVOKE SlideDown, OFFSET baddie_2
	
	INVOKE Collision, OFFSET projectile, OFFSET bounceStar, OFFSET explosion
	
	INVOKE CollisionDie, OFFSET shootingShip, OFFSET bounceStar
	;;COLLISION DEALING
	;INVOKE Collision, OFFSET projectile, OFFSET shotAt
	;if eax=1:
	;	increase counter of points. do not change projectile ammo
	;	INVOKE reset_objects, OFFSET projectile, OFFSET shotAt
	;else
	;	decrease projectile ammo by 1. no change to counter
	
	ret
GameLogic ENDP
;; Define the function GameLogic
;; Since we have thoroughly covered defining functions in class, its up to you from here on out...
	
END
