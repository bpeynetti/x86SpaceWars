; #########################################################################
;
;   game.asm - Assembly file for EECS205 Assignment 4/5
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
	clickStar 	SPRITE <?,?,?,?,?,?>
	ship 		SPRITE <?,?,?,?,?,?>
	bounceStar 	SPRITE <10011111100b,1110111100b,?,?,?,?>
	clickStar2	SPRITE <0,0,0,0,0,0>
	mouseClick 	POINT <?,?>
	mouseLoc 	POINT <?,?>
	shootingShip SPRITE <319,420,0,?,?,?>
	projectile SPRITE <?,?,?,?,?,0>
	
	baddie_1 SPRITE <?,1,?,1,?,0> ;first asteroid
	baddie_2 SPRITE <?,1,?,0,?,0> ;second asteroid
	
	explosion SPRITE <?,?,?,?,?,?>;explosion thingy
	
	burp BYTE "music.wav",0
	
;;
	counter DWORD 0
	hits DWORD 0
	ammo DWORD 20
	dead DWORD 0
	;last element (aa) determines if it's visible or not
	
	keyPress 	DWORD ?
	angle 		DWORD ?


.CODE

	EXTERNDEF STDCALL PlaySoundA: NEAR
	PlaySoundA PROTO STDCALL :DWORD,:DWORD,:DWORD
	PlaySound equ <PlaySoundA>
	SND_ASYNC = 1h
	SND_LOOP = 0008h
	SND_FILENAME = 20000h
	
	
	
	GameInit PROC
	;called once. it initializes things/preprocessing/stuff like that
	
	INVOKE PlaySound, OFFSET burp, 0, SND_ASYNC+SND_FILENAME
	mov mouseClick.x, 319
	mov mouseClick.y, 239

	INVOKE RandomNum 
	;eax has offset left, and right
	mov baddie_1.x,eax
	add baddie_1.x,319
	
	INVOKE RandomNum
	add baddie_2.x,319 
	sub baddie_2.x,eax
	
	xor eax,eax
	mov mouseLoc.x,eax
	mov mouseLoc.y,eax
	mov dead,0
	mov angle,0 	;set an initial angle
	
	mov hits,0
	ret
	GameInit ENDP
	
	
	GameMain PROC USES ebx ecx edx mouseStatus:DWORD, keyDown:DWORD, keyUp:DWORD
	LOCAL xshift:DWORD, yshift:DWORD, shoot:DWORD
	;initialize local variables
	mov xshift,0
	mov yshift,0 
	mov shoot,0
	
	;mouseStatus:
	;	<31:20> x coordinate
	;	<19:8> y coordinate
	;	<1>	left button (1 = pressed)
	;	<0>	right button (1 = pressed)

	;check if mouse pressed
	mov ebx,mouseStatus
	and ebx,2h	;eliminate all except the left button
	cmp ebx,0
	jz mouse_not_clicked
	xor esi,esi
	
	;if pressed
	mov ebx,mouseStatus
	mov ecx,ebx
	;get x coordinate (bits 31:20)
	shr ebx,20
	mov mouseClick.x,ebx
	and ecx,0fff00h
	shr ecx,8
	mov mouseClick.y,ecx
	mov angle,0
mouse_not_clicked:

	add angle,180
	
	
	
	
	;DEAL WITH KEYS (TRANSLATION UP/DOWN)
	;if right is pressed, then increase xinc by one
	cmp keyDown,VK_RIGHT	;right key
	jnz key_right_not_pressed
	mov xshift,10
	jmp vertical_shift
key_right_not_pressed:

	cmp keyDown,VK_LEFT	;left key
	jnz key_left_not_pressed
	mov xshift,-10
key_left_not_pressed:

vertical_shift:
	cmp keyDown,VK_DOWN
	jnz down_not_pressed
	add yshift,10
down_not_pressed:
	cmp keyDown,VK_UP
	jnz up_not_pressed
	sub yshift,10
	
	;xor edx,edx
up_not_pressed:
	;continue
	
	;DEAL WITH SHOOTING
	;shoot with spacebar
	cmp keyDown,VK_SPACE
	jnz space_not_pressed
	mov shoot,1
	
space_not_pressed:
	
	
	INVOKE GameLogic, xshift, yshift, mouseStatus, shoot
	INVOKE GameRender
	;calls GameLogic to handle sprite animation (moving, checking collisions, etc)
	;call GameRender to draw things on screen with Rotate/BasicBlit

	ret
GameMain ENDP

	
	;; Define the functions GameMain and GameInit
	;; Since we have thoroughly covered defining functions in class, its up to you from here on out...
		
END
