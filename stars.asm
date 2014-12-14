; #########################################################################
;
;   stars.asm - Assembly file for EECS205 Assignment 1
;
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

    include stars.inc

.CODE

; Routine which uses DrawStarReg to create all the stars
DrawAllStars PROC 

;first one
mov esi,120
mov edi,120
CALL DrawStarReg
;second one
mov esi,140
mov edi,140
CALL DrawStarReg
;third
mov esi,160
mov edi,160
CALL DrawStarReg
;4
mov esi,180
mov edi,180
CALL DrawStarReg
;5
mov esi,200
mov edi,200
CALL DrawStarReg
;6
mov esi,220
mov edi,220
CALL DrawStarReg
;7
mov esi,140
mov edi,120
CALL DrawStarReg
;8
mov esi,160
mov edi,120
CALL DrawStarReg
;9
mov esi,180
mov edi,120
CALL DrawStarReg
;10
mov esi,200
mov edi,122
CALL DrawStarReg
;11
mov esi,550
mov edi,400
CALL DrawStarReg
;12
mov esi,500
mov edi,300
CALL DrawStarReg
;13
mov esi,330
mov edi,320
CALL DrawStarReg
;14
mov esi,13
mov edi,12
CALL DrawStarReg
;15
mov esi,400
mov edi,100
CALL DrawStarReg
;16
mov esi,456
mov edi,123
CALL DrawStarReg
;17
mov esi,450
mov edi,379
CALL DrawStarReg
;18
mov esi,400
mov edi,398
CALL DrawStarReg
;19
mov esi,251
mov edi,261
CALL DrawStarReg
;20
mov esi,250
mov edi,260
CALL DrawStarReg

mov esi,300
mov edi,220
CALL DrawStarReg

mov esi,280
mov edi,222
CALL DrawStarReg

mov esi,260
mov edi,222
CALL DrawStarReg

mov esi,240
mov edi,222
CALL DrawStarReg

    ;; Place your code here
	
	

    ret             ;; Don't delete this line
    
DrawAllStars ENDP

END
