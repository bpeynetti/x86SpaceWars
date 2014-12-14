; #########################################################################
;
;   trig.asm - Assembly file for EECS205 Assignment 3
;
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

    include trig.inc	

.DATA

;;  These are some useful constants (fixed point values that correspond to important angles)
PI_HALF = 102943           	;;  PI / 2
PI =  205887	                ;;  PI 
TWO_PI	= 411774                ;;  2 * PI 
PI_INC_RECIP =  5340353        	;;  256 / PI   (use this to find the table entry for a given angle
	                        ;;              it is easier to use than divison would be)
PI_MAGIC_NUMBER = 00517CC1h	; 256/PI in fixed (from hex) 0000 0000 0101 0001 . 0111 1100 1100 0001
Negative DWORD 0	;intial value, flag for negative or not
PiHalf DWORD PI_HALF
PiPi DWORD PI
TwoPi DWORD TWO_PI
PiMagic DWORD PI_INC_RECIP

.CODE

;; Define the functions FixedSin and FixedCos

FixedSin PROC USES ecx ebx edx esi dwAngle: FIXED
	;-- start here
	; the angle is given in radians
	; get value
	
	 xor ebx,ebx	;free one register to 0
	 mov Negative,0
	
	;assuming it's the correct range:
	;multiply angle by my magic number
	mov eax,dwAngle	;store in here
	mov esi,dwAngle ;and also here
	; account for all regions: (pi/2,pi],(pi,3pi/2],(3pi/2,2pi]
	; divide and check multiple to know where i am?
	
; test_quadrants:
check:
	cmp eax,TWO_PI
	jge make_smaller
	
	cmp eax,0
	jge continue
make_bigger:
	add eax,TWO_PI
	jmp check
make_smaller:
	sub eax,TWO_PI
	jmp check
continue:
	mov esi,eax	;new good angle
	cmp esi,PI_HALF
	jle get_position
	cmp esi,PI
	jl second_quadrant
	jmp third_fourth_quadrant
	; cmp esi,threehalfpi
	; jl third_quadrant
	; jmp fourth_quadrant	

second_quadrant:
	;second quadrant
	;sin(x)=sin(pi-x)
	;subtract x from pi
	cmp esi,PiHalf	;is the angle pi/2?
	jnz keep
	mov eax,10000h	;store 1.0000 0000 0000 0000
	jmp done
keep:
	xor edx,edx
	mov edx,PiPi
	sub edx,esi	;pi-x
	mov eax,edx	;move angle back to ebx
	jmp get_position
	
third_fourth_quadrant:
	;third or fourth quadrants
	;sin(x+pi)=-sin(x)
	;get x. set negative
	xor ecx,ecx
	mov ecx,1
	mov Negative,ecx
	mov ebx,esi	;get angle
	sub ebx,PiPi	;x=angle-pi
	;now we know it's negative, simply test again for quadrants
	mov eax,ebx
	jmp continue

get_position:	
	 mov ecx,PI_INC_RECIP
	 imul ecx	;multiply. result stored in edx and eax
	 ;muliplying 2 fixed, so take integer part
	 ;we now know the # of the array we need to reach
	 ;only care about integer, so take edx part (integer of the two fixed point multiplications)
	 mov eax,edx	;eax<-element # in array
	 shl eax,1	;eax<-eax*2 (WORD array)
	 mov ecx, OFFSET SINTAB 	;get address of SINTAB
	 add ecx,eax	;get ptr to location in SINTAB array
	 xor eax,eax
	 mov ax,(WORD PTR [ecx])	;get WORD at that ptr
	; shl ax,8	;put it at fixed location. (16-bit address shifted left by 8)
	xor ebx,ebx	;set as 0
	mov ebx,1	;put a 1
	cmp Negative,ebx	;check negative
	jnz done	
	;need to do *-1. just subtract it twice
	xor edx,edx	
	mov edx,eax
	sub edx,eax	;should be at 0 (eax-eax)
	sub edx,eax	;should be at -eax (0-eax)
	mov eax,edx	;put it for return in eax
done: ;nothing, just done
	;eax is the return value. type is fixed (first 16 should be 0, and rest is 
	ret
FixedSin ENDP


FixedCos PROC USES ebx	dwAngle: FIXED
	
	;cos(x)=sin(x+pi/2)
	 mov ebx,dwAngle
	 add ebx,PiHalf ;x+pi/2
	 INVOKE FixedSin, ebx
	;done
	ret
FixedCos ENDP

END
