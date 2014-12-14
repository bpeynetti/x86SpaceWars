; #########################################################################
;
;   render.asm - Assembly file for EECS205 Assignment 4/5
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
	
.DATA


.CODE
GameRender PROC

;calls RotateBlit and other routines
;to draw things onto the screen

INVOKE BeginDraw

INVOKE DrawAllStars
cmp ammo,0
jl game_over

cmp dead,1
jz dead_russ

;INVOKE RotateBlit, OFFSET StarBitmap,clickStar.x,clickStar.y, 0
INVOKE RotateBlit, OFFSET asteroid_000,clickStar2.x,clickStar2.y,clickStar2.a
xor eax,eax
INVOKE RotateBlitA, OFFSET fighter_000,bounceStar.x,bounceStar.y,clickStar.a
INVOKE RotateBlit, OFFSET russppm, shootingShip.x,shootingShip.y,0

INVOKE RotateBlitProj, OFFSET laserppm, projectile.x,projectile.y,0,OFFSET projectile

INVOKE RotateBlitProj, OFFSET asteroid_000,baddie_1.x,baddie_2.y,0,OFFSET baddie_1
;;INVOKE RotateBlitProj, OFFSET asteroid_000,baddie_2.x,baddie_2.y,0,OFFSET baddie_2

INVOKE DrawInt, 600, 20, hits
INVOKE DrawInt, 600, 40, ammo

check_explosion_status:
	cmp count_explosion,0
	jz skipping
	cmp count_explosion,1
	jg keep_checking_1
	INVOKE RotateBlit, OFFSET nuke_000, explosion.x,explosion.y,0
	inc count_explosion
	jmp skipping
	
keep_checking_1:
	cmp count_explosion,15
	jg keep_checking_2
	INVOKE RotateBlit, OFFSET nuke_001, explosion.x,explosion.y,0
	inc count_explosion
	jmp skipping
	
keep_checking_2:
	cmp count_explosion,30
	jg keep_checking_3
	INVOKE RotateBlit, OFFSET nuke_002, explosion.x,explosion.y,0
	inc count_explosion
	jmp skipping

keep_checking_3:
	cmp count_explosion,45
	jg keep_checking_4
	INVOKE RotateBlit, OFFSET nuke_003, explosion.x,explosion.y,0
	inc count_explosion
	jmp skipping

keep_checking_4:
	cmp count_explosion,60
	jg skipping
	INVOKE RotateBlit, OFFSET nuke_004, explosion.x,explosion.y,0
	inc count_explosion
	jmp skipping
	
	cmp count_explosion,75
	jge reset_explosion
	INVOKE RotateBlit, OFFSET nuke_005, explosion.x,explosion.y,0
	jmp skipping
	
reset_explosion:
	mov count_explosion,0
	jmp skipping
	
game_over:
	cmp dead,1
	jnz skipping
dead_russ:
	INVOKE RotateBlit, OFFSET russppm, 319,219,clickStar.a
	
skipping:

INVOKE EndDraw

ret
GameRender ENDP
;; Define the function GameRender
;; Since we have thoroughly covered defining functions in class, its up to you from here on out...
	
END
