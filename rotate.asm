; #########################################################################
;
;   rotate.asm - Assembly file for EECS205 Assignment 3
;
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

    include trig.inc		; Useful prototypes
    include rotate.inc		; 	and definitions


.DATA
	;; You may declare helper variables here, but it would probably be better to use local variables
sinx DWORD ?
cosx DWORD ?
Xmoving DWORD 1
Ymoving DWORD 1
counterss DWORD 0
randomvar DWORD ?
count_explosion DWORD 0

.CODE

;-----
; BasicBlit simply sets values in correct pointers
; and calls BlitReg to output bitmap where it should be
;-----

BasicBlit PROC USES ecx ebx edx edi esi	lpBmp:PTR EECS205BITMAP, xcenter:DWORD,	ycenter:DWORD	;---------
	; sets the values to call BlitReg
	; esi=x coordinate
	; edi=y coordinate
	; edx=ptr to bitmap to draw
	;----------
	mov esi,xcenter ;esi takes x center
	mov edi,ycenter ;edi takes y center
	mov edx,lpBmp	;lpBmp takes ptr to bitmap
	
	Call BlitReg
	;returns nothing
	ret
BasicBlit ENDP

;--------------------------------------------------------------
;  RotateBlit
;  input all values from stack, also for safety, say it uses all registers

RotateBlit PROC USES eax ebx ecx edx edi esi,
	lpBmp: PTR EECS205BITMAP,
	xcenter:DWORD, ycenter:DWORD, angle:DWORD
	 LOCAL shiftx:DWORD, shifty:DWORD, dstWidth:DWORD, dstHeight:DWORD, srcX:DWORD, srcY:DWORD, mineColor:BYTE, Position:DWORD, start_Pos:DWORD, curr_pos:DWORD, dstX:DWORD, dstY:DWORD, screenx:DWORD, screeny: DWORD
	;---- rotate function starts here
	;find ptr for starting position and store it in start_Pos
		;;
		
		;;;FOR RANDOM NUMBER GENERATOR
		inc counterss
		;;;;;
		;;;;;
	
	 mov curr_pos,0
	 mov esi,lpBmp
	 xor ecx,ecx
	 mov ecx,xcenter
	 mov ebx,ycenter
		
	mov edx, (EECS205BITMAP PTR [esi]).dwWidth
	shr edx,1	;shift by one
	sub ecx, edx ;ecx <- (x-dwWidth/2)
		
	mov edx, (EECS205BITMAP PTR [esi]).dwHeight
	shr edx,1
	sub ebx,edx ;ebx <- (y-dwHeight/2)
		
	mov eax,dwPitch ;find pitch
	mul ebx			;eax<-dwPitch*(y-dwHeight/w)
	add eax,ecx		;eax<-dwPitch*(y-dwHeight/w) + (x-dwWidth/2)
	add eax,lpDisplayBits
	
	;start <- lpDisplayBits + dwPitch*(y-dwHeight/2) + (x-dwWidth/2)
	mov start_Pos,eax
	
	xor edx,edx
	xor ecx,ecx
	xor eax,eax
	;GET SIN AND COS OF ANGLE
	xor eax,eax
	mov eax,angle
	INVOKE FixedCos, eax 
	mov cosx,eax	;cosx <=cos(angle)
	
	xor eax,eax
	mov eax,angle
	INVOKE FixedSin, eax
	mov sinx,eax	;sinx <=sin(angle)

	; ;--------
	; ;shiftx = (EECS205BITMAP PTR [esi]).dwWidth * cosa/2 - (EECS205BITMAP PTR [esi]).dwHeight * sina/2;
	; ;shifty = (EECS205BITMAP PTR [esi]).dwHeigth * cosa/2 + (EECS205BITMAP PTR [esi]).dwHeight * sina/2;
	; ;dstWidth = (EECS205BITMAP PTR [esi]).dwWidth + (EECS205BITMAP PTR [esi]).dwHeight;
	; ;dstHeight=dstWidth
	
	; ;for (dstX = -dstWidth; dstX < dstWidth; dstX++) {
	; ;	for (dstY = -dstHeight; dstY < dstHeight; dstY++) {
	; ;		srcX = dstX*soca + dstY*sina
	; ;		srcY = dstY*cosa - dstX*sina
	; ;		if (srcX >= 0 && srcY < (EECS205BITMAP PTR [esi]).dwWidth && srcY >= 0 &&
	; ;			srcY < (EECS205BITMAP PTR [esi]).dwHeight && (xcenter+dstX-shiftX) >= 0 &&
	; ;			(xcenter+dstX-shiftX) <=639 && (ycenter+dstY-shiftY) >=0 && (ycenter+dstY-shiftY) <=479 &&
	; ;			bitmap pixel (srcX,srcY) is not transparent) then
	; ;				
	; ;					copy color value from bitmap(srcX,srcY) to screen
	; ;						screen == xcenter+dstX-shiftX, ycenter+dstY-shifty)
	; ;--------------------------------------------------------
	
	;shiftx = (EECS205BITMAP PTR [esi]).dwWidth * cosa/2 - (EECS205BITMAP PTR [esi]).dwHeight * sina/2;
	mov esi,lpBmp
	mov eax,cosx
	mov ebx,(EECS205BITMAP PTR [esi]).dwWidth
	;shl ebx,16 ;dont shift it
	imul ebx ;multiply to get (dwWidth*cosa). currently fixed. decimal point stays at same place as before
	sar eax,1 ;divide by 2, keep it arithmetic. FIXED
	;eax<=(dwWdith*cosx/2)
	mov shiftx,eax	;store in shiftx. will subtract later
	mov eax,sinx
	sar eax,1 ;divide by 2, keep it arithmetic
	mov ebx,(EECS205BITMAP PTR [esi]).dwHeight
	;sal ebx,16 ;shift it to make it fixed as well
	imul ebx ;multiply to get (dwHeight*sina). currently fixed. integer in edx, decimal in eax
	sar ebx,1; ebx<-(dwHeight*sina)/2
	sub shiftx,eax
	;truncate to nearest integer
	mov eax,shiftx
	sar eax,16
	mov shiftx,eax
	
	;shifty = (EECS205BITMAP PTR [esi]).dwHeight * cosa/2 + (EECS205BITMAP PTR [esi]).dwHeight * sina/2;
	mov eax,cosx
	mov ebx,(EECS205BITMAP PTR [esi]).dwHeight
	imul ebx ;multiply to get (dwWidth*cosa). currently fixed. aall in eax, good
	sar eax,1 ;divide by 2, keep it arithmetic (dwHeigth*cosa)/2
	mov shifty,eax	;store in shiftx. will subtract later
	mov eax,sinx
	mov ebx,(EECS205BITMAP PTR [esi]).dwWidth
	imul ebx ;multiply to get (dwHeight*sina). currently fixed. integer in edx, decimal in eax
	sar eax,1 ;divide by 2, keep it arithmetic (dwHeight*sina)/2
	add shifty,eax
	;truncate to nearest integer
	mov eax,shifty
	sar eax,16
	mov shifty,eax
	
	; ;dstWidth = (EECS205BITMAP PTR [esi]).dwWidth + (EECS205BITMAP PTR [esi]).dwHeight;
	 xor ebx,ebx
	 mov ebx,(EECS205BITMAP PTR [esi]).dwWidth
	 add ebx,(EECS205BITMAP PTR [esi]).dwHeight
	 mov dstWidth,ebx

	 ;dstHeight=dstWidth
	 mov dstHeight,ebx
	
	; ;clear registers
	 xor eax,eax
	 xor ebx,ebx
	 xor ecx,ecx
	 xor edx,edx
	 xor edi,edi
	
	; ;start with -dstWidth
	 sub edi,dstHeight 
	 mov dstY,edi
	 jmp outer_for_c
 outer_loop:
	xor edx,edx
	sub edx,dstWidth	;start with -dstWidth
	mov dstX,edx	;store in dstY
	jmp inside_for_c
inside_loop:
		;srcx=dstX*cosa + dstY*sina
		mov eax,dstX
		imul cosx
		mov ebx,eax
		;add second term
		mov eax,dstY
		imul sinx
		add ebx,eax
		sar ebx,16
		;truncate to nearest integer from 32 bit fixed point, decimal at 16th bit
		mov srcX,ebx
		
		;srcY=dstY*cosa - dstX*sina
		xor eax,eax
		xor ebx,ebx
		mov eax,dstY
		imul cosx
		mov ebx,eax
		;add second term
		mov eax,dstX
		imul sinx
		sub ebx,eax
		;truncate to nearest integer (from fixed point)
		sar ebx,16
		mov srcY,ebx
		
		;big IF
		;srcX>=0
		mov ebx,srcX
		cmp ebx,0
		jl end_if
		
		;srcX<(EECS205BITMAP PTR [esi]).dwWidth
		cmp ebx,(EECS205BITMAP PTR [esi]).dwWidth
		jg end_if
		
		;srcY>=0
		mov ebx,srcY
		cmp ebx,0
		jle end_if
		
		;srcY<(EECS205BITMAP PTR [esi]).dwHeight
		cmp ebx,(EECS205BITMAP PTR [esi]).dwHeight
		jge end_if
		
		;(xcenter+dstX-shiftX) >=0
		xor ebx,ebx
		mov ebx,xcenter
		add ebx,dstX
		sub ebx,shiftx
		cmp ebx,0
		jl end_if
		
		;(xcenter+dstX-shiftx) <=639
		cmp ebx,639
		jg end_if
		mov screenx,ebx
		;keep value in screenx because we will use it later on to copy color values
		
		;(ycenter+dstY-shiftY) >=0
		xor ecx,ecx
		mov ecx,dstY
		add ecx,ycenter
		sub ecx,shifty
		cmp ecx,0
		jl end_if
		
		;(ycenter+dstY-shiftY) <=479		
		cmp ecx,479
		mov screeny,ecx
		jg end_if
		
		;get color
		;bitmap: rows*dwWidth+cols
		mov eax, srcY
		mul (EECS205BITMAP PTR [esi]).dwWidth
		add eax,srcX
		add eax,4
		mov cl, BYTE PTR [(EECS205BITMAP PTR [esi]).lpBytes + eax]	;color into cl
		cmp cl, (EECS205BITMAP PTR [esi]).bTransparent;
		jz end_if
		
		;point in screen is lpDisplayBits[screeny*dwPitch+screenx] all BYTES
		mov eax,screeny
		mul dwPitch
		add eax,screenx
		add eax,lpDisplayBits
		mov BYTE PTR [eax], cl
			
end_if:	
	inc dstX
inside_for_c:
	mov edx,dstX
	cmp edx,dstWidth
	jl inside_loop
	
	;fix curr_pos by decreasing by dstWidth and adding 1 to dwPitch
	inc dstY ;dstX++
outer_for_c:	;condition for outer for loop
	mov edi,dstY
	cmp edi,dstHeight
	jl outer_loop	;as long as dstX<dstWidth	
	
	;--END, return 
	ret
RotateBlit ENDP

RotateBlitA PROC uses ebx ecx esi lpBmp:PTR EECS205BITMAP, xcenter:DWORD, ycenter:DWORD, angle:DWORD

mov esi,lpBmp
mov eax, xcenter
mov ebx, ycenter
mov ecx, angle

shr eax,2
shr ebx,2

INVOKE RotateBlit, esi, eax, ebx, ecx

ret
RotateBlitA ENDP


Bounce PROC USES eax ebx ecx esi lpBmp: PTR EECS205BITMAP, sprt: PTR SPRITE
LOCAL xcenter:DWORD, ycenter:DWORD
	mov esi,lpBmp
	mov edi,sprt
	mov eax,(SPRITE PTR[edi]).x
	mov xcenter,eax
	mov eax,(SPRITE PTR[edi]).y
	mov ycenter,eax
	xor eax,eax
	;get coordinates
	;start moving up and to the right
	;if reach top border, change moving vertical to down
	;if reach right border, change moving horiz to left
	;if reach left border, change moving horiz to right
	;if reach bottom border, change moving vertical to up
	mov eax,Xmoving
	mov ebx,Ymoving
	
	;if(horiz_mov=1)
		;if (xcenter+width/2+1>=rightlimit)
			;horiz_mov=-1
x_pos:	
	cmp eax,1
	jnz x_neg
	mov ecx,(EECS205BITMAP PTR[esi]).dwWidth
	shr ecx,1
	add ecx,xcenter
	add ecx,1
	cmp ecx,100101010000b
	jle vertical
	
	mov eax,-1
	mov Xmoving,eax
;	imul eax,2
	jmp vertical
	
x_neg:
	;if(horiz_mov=-1)
		;if (xcenter-width/2-1<=0)
			;horiz_mov=1
	cmp eax,-1
	jnz vertical
	mov ecx,(EECS205BITMAP PTR[esi]).dwWidth
	shr ecx,1
	neg ecx
	add ecx,xcenter
	sub ecx,3
	cmp ecx,0
	jge vertical
	
	mov eax,1
	mov Xmoving,eax
;	imul eax,2
	
	;if(vert_mov=1)
		;if(ycenter+height/2+1>=verticallimit)
			;vertical_mov=-1
	;if(vert_mov=-1)
		;if(ycenter-height/2-1<=0)
			;vertical_mov=1
vertical:
	cmp ebx,1
	jnz y_neg
	mov ecx,(EECS205BITMAP PTR[esi]).dwHeight
	shr ecx,1
	add ecx,ycenter
	add ecx,4
	cmp ecx,11100010000b
	jle continue
	
	mov ebx,-1
	mov Ymoving,ebx
;	imul ebx,2
	jmp continue

y_neg:
	cmp ebx,-1
	jnz continue
	mov ecx,(EECS205BITMAP PTR[esi]).dwHeight
	shr ecx,1
	neg ecx
	add ecx,ycenter
	sub ecx,4
	cmp ecx,0
	jge continue
	
	mov ebx,1
	mov Ymoving,ebx
;	imul ebx,2

continue:

	;xcenter=xcenter+horiz_mov
	;ycenter=ycenter+vertical_mov
	add eax,xcenter
	add ebx,ycenter
	
	;make these the new points
	mov (SPRITE PTR[edi]).x,eax
	mov (SPRITE PTR[edi]).y,ebx
	
	
		
	ret
Bounce ENDP

MoveHoriz PROC USES ebx ecx edx esi sprt:PTR SPRITE, x_inc:DWORD

	;simply moves by x locations
	mov esi, sprt
	mov ebx,x_inc
	add ebx,(SPRITE PTR[esi]).x
	cmp ebx,10
	jl done
	cmp ebx,620
	jge done
	mov (SPRITE PTR[esi]).x,ebx

done:

ret
MoveHoriz ENDP

MoveVertical PROC USES ebx ecx sprt:PTR SPRITE, y_inc:DWORD
	;simply moves by x locations
	mov esi, sprt
	mov ebx,y_inc
	add ebx,(SPRITE PTR[esi]).y
	cmp ebx,10
	jl done
	cmp ebx,470
	jge done
	mov (SPRITE PTR[esi]).y,ebx

done:

ret
MoveVertical ENDP

ShootProj PROC USES eax ebx ecx esi edi proj:PTR SPRITE, shoot:DWORD, shooter:PTR SPRITE

	mov esi,proj
	mov edi,shooter

	cmp shoot,1
	jz start_shooting
	cmp (SPRITE PTR [esi]).aa,1
	jz move_projectile
	jmp end_fun
	
start_shooting:
	;enable visibility of projectile
	dec ammo
	mov (SPRITE PTR [esi]).aa,1
	;set its starting point as center of the shooter
	mov eax,(SPRITE PTR [edi]).x
	mov ebx,(SPRITE PTR [edi]).y
	mov (SPRITE PTR [esi]).x,eax
	mov (SPRITE PTR [esi]).y,ebx
	jmp end_fun
move_projectile:
	;shoot projectile upwards
	;make sure to make it disappear if it reaches top of screen
	mov eax,(SPRITE PTR [esi]).x
	mov ebx,(SPRITE PTR [esi]).y
	sub ebx,1
	cmp eax,10
	jge keep_showing
disappear:
	;turn visibility off
	mov (SPRITE PTR [esi]).aa,0
	mov (SPRITE PTR [esi]).x,0
	mov (SPRITE PTR [esi]).y,0

keep_showing:
	mov (SPRITE PTR [esi]).x,eax
	mov (SPRITE PTR [esi]).y,ebx
	
	add counterss,ebx
end_fun:
ret
ShootProj ENDP

Collision PROC USES ebx ecx esi edi proj:PTR SPRITE, objective:PTR SPRITE, explosionSprite:PTR SPRITE
LOCAL hitx:DWORD, hity:DWORD
;;if the projectile is in the same y,
;;turn it off
	mov esi,proj
	mov edi,objective
	mov eax,(SPRITE PTR [esi]).y ;proj.y
	mov ebx,(SPRITE PTR [edi]).y ;objective.
	shr ebx,2
	
	cmp eax,ebx
	jnz skip
	mov hity,eax
	
check_hit_horiz:
	mov eax,(SPRITE PTR [esi]).x ;get proj.x 
	mov ebx,(SPRITE PTR [edi]).x ;get objective.x 
	shr ebx,2
	mov edx,ebx
	add edx,20
	sub ebx,20
	jmp check_loop
myloop:
	mov hitx,ebx
	cmp ebx,eax
	jz its_a_hit
	inc ebx
check_loop:
	cmp ebx,edx
	jle myloop
	;not found, so skip 
	jmp skip

its_a_hit:
	mov (SPRITE PTR [esi]).aa,0
	mov (SPRITE PTR [esi]).x,-1
	mov (SPRITE PTR [esi]).y,-1
	mov (SPRITE PTR [edi]).x,10011111100b
	mov (SPRITE PTR [edi]).y,1110111100b
	inc hits
	mov eax,explosionSprite
	mov ebx,hitx
	mov ecx,hity
	mov (SPRITE PTR [eax]).x,ebx
	mov (SPRITE PTR [eax]).y,ecx
	mov count_explosion,1
	
	;increase ammo by 1
	inc ammo
	inc ammo
skip:
;;if collision, eax=1, else, eax=0
;this is used in GameLogic to RESET projectile 
ret
Collision ENDP

CollisionDie PROC USES ebx ecx esi edi edx shooter:PTR SPRITE, baddie:PTR SPRITE
;;if the projectile is in the same y,
;;turn it off
	mov esi,shooter
	mov edi,baddie
	mov eax,(SPRITE PTR [esi]).y ;baddie.y
	mov ebx,(SPRITE PTR [edi]).y ;shooter y position.
	shr ebx,2
	
check_hit_vertical:
	mov edx,ebx
	add edx,30
	sub ebx,30
	jmp check_loop_v
myloop_1:
	cmp ebx,eax
	jz check_hit_horiz
	inc ebx
check_loop_v:
	cmp ebx,edx
	jle myloop_1
	;not found, so skip 
	jmp skip
	
;;;;;;;;;;;;;;;;
check_hit_horiz:
	mov eax,(SPRITE PTR [esi]).x ;get baddie.x 
	mov ebx,(SPRITE PTR [edi]).x ;get shooter.x 
	shr ebx,2
	mov edx,ebx
	add edx,30
	sub ebx,30
	jmp check_loop
myloop:
	cmp ebx,eax
	jz its_a_hit
	inc ebx
check_loop:
	cmp ebx,edx
	jle myloop
	;not found, so skip 
	jmp skip

its_a_hit:
	mov (SPRITE PTR [esi]).aa,0
	mov (SPRITE PTR [esi]).x,-1
	mov (SPRITE PTR [esi]).y,-1
	mov (SPRITE PTR [edi]).x,100111111b
	mov (SPRITE PTR [edi]).y,11101111b
	mov dead,1
	;increase ammo by 1
skip:
;;if collision, eax=1, else, eax=0
;this is used in GameLogic to RESET projectile 
ret
CollisionDie ENDP

RandomNum PROC USES ebx edx
LOCAL abc:DWORD

	mov eax,abc
	imul counterss
	add eax,counterss
	add eax,ecx
	add eax,esp
	sub eax,7638h
	sub eax,edi
	add eax,randomvar
	and eax,0ffh ;and it to be max 255
	;this is the offset from the center

ret
RandomNum ENDP


RotateBlitProj PROC USES ebx ecx edx esi lpBmp:PTR EECS205BITMAP, xcenter:DWORD, ycenter:DWORD, angle:DWORD, mySprite:PTR SPRITE

	mov esi, mySprite
	mov eax,(SPRITE PTR [esi]).aa
	cmp eax,0
	jz do_nothing
		INVOKE RotateBlit, lpBmp, xcenter, ycenter, angle
	
do_nothing:

ret
RotateBlitProj ENDP

SlideDown PROC USES ebx ecx edx myObject:PTR SPRITE

;if past the bottom, set to -100
	mov edi, myObject
	mov ebx, (SPRITE PTR [edi]).aa
	cmp ebx,0 ; check if not visible
	jz enable_object
	
sliding_down:
	inc (SPRITE PTR [edi]).y	;simply increment
	mov ecx,(SPRITE PTR [edi]).y
	
	cmp ecx,480			;out of the screen!
	jg enable_object	;reset the object, no change to lives yet?
	
	jmp end_SlideDown
	
	
enable_object:
	;set starting position, and slide down
	mov (SPRITE PTR [edi]).y,-30
	INVOKE RandomNum
	mov edx,(SPRITE PTR [edi]).xx
	mov (SPRITE PTR [edi]).x,215
	cmp edx,0
	jge right_side
left_side:
	sub (SPRITE PTR [edi]).x,eax
right_side:
	add (SPRITE PTR [edi]).x,eax
	
	mov (SPRITE PTR [edi]).aa,1
	
end_SlideDown:

ret
SlideDown ENDP

END
