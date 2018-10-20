;;; ---- ADDRESSES
AUX_C     = $900e	; bits 4-7: auxillary colour
SCR_C     = $900f	; bits 0-2: border color 
                        ; bits 4-7: background color
CHR_C     = $0286	; character color (dec: 646)

COLOR_MEM = $9600	; start of colour memory 
SCRN_MEM1 = $1e00	; start of screen memory
SCRN_MEM2 = $1f00	; middle of screen memory
CHAR_MEM  = $1c00	; start of character memory

RASTER	  = $9004
	
;;; ---- ZERO PAGE
SCRN_LSB    = $00	; LSB of screen memory address
SCRN_MSB    = $01	; MSB Of screen memory address	
CLRM_LSB    = $04	; LSB of colour memory address
CLRM_MSB    = $05	; MSB Of colour memory address
CURR_SPRITE = $08	

;;; ---- CONSTANTS
CHAR_FORWARD = #$00	; character facing forward
CHAR_BCKWARD = #$01	; character facing backward
CHAR_SIDE    = #$02	; character facing to the right
FRAME        = #$03	; frame counter
	
	processor	6502
	org		$1001

	dc.w	end
	dc.w	1234
	dc.b	$9e, " 4110", 0
end:	dc.w	0

start:
	lda	#12	; border purple, screen black (ref p. 265)
	sta 	SCR_C
	lda	#144	; light orange (ref p. 264)
	sta	AUX_C
	lda	#01	; white characters
	sta	CHR_C

	lda	#$20
	ldx	#$00	
clear_loop:			; clear the screen
	sta	SCRN_MEM1,X
	sta	SCRN_MEM2,X
	inx
	bne	clear_loop

	lda	#255		; custom character set
	sta	$9005

	;; now, load the sprite into memory
 	ldx	#0
load:	lda	sprite,X
 	sta	CHAR_MEM,X	
 	inx
 	cpx	#96
 	bne	load
	
	;; store screen address for calculations later  
	lda 	#$00            ; load LSB
	sta 	SCRN_LSB
	lda 	#$1e            ; load MSB
	sta 	SCRN_MSB

	;; store the colour memory address for calculations later
	lda	#$00		; load LSB
	sta	CLRM_LSB		
	lda	#$96		; load MSB
	sta	CLRM_MSB
	
	lda	CHAR_FORWARD
	sta	CURR_SPRITE
	jsr	drawChar
	
;;; ----- INPUT
input
	jsr 	startFrame
	lda 	$00c5   ; current key pressed (pg 172)
	;; cmp 	#9      ;w
	;; beq 	up
	;; cmp 	#17     ;a
	;; beq 	left    
	;; cmp 	#41     ;s
	;; beq 	down
	cmp 	#18     ;d
	beq 	right
	jmp 	input
up:	
	ldy 	#0
	jsr 	erase

	ldy 	#21		; why tf is this 21 when its 22??
	jsr 	subOffset
	jmp 	doneInput
down:	
	jsr 	erase
	ldy 	#22
	jsr 	addOffset
	jmp 	doneInput
left:	
	jsr 	erase
	ldy 	#1
	jsr 	subOffset      ; going left moves faster than all other directions??
	jmp 	doneInput
right:	
	jsr 	erase
	ldy 	#1
	jsr 	addOffset
doneInput:	
	jsr	drawChar
	jmp	input

;;; ----- MOVEMENT ROUTINES

; needs move increment in Y register
addOffset
  	tya                     ;2      ; move increment in acumulator
  	clc                     ;2      ; clear the carry
  	adc 	SCRN_LSB        ;3      ; add to LSB
  	sta 	SCRN_LSB	;3      ; store result in LSB

	tya			;2
	clc			;2
	adc	CLRM_LSB	;3
	sta	CLRM_LSB	;3
	
	bcc	addOffset_no_carry ;2

	inc	SCRN_MSB	;5
	inc	CLRM_MSB	;5

addOffset_no_carry:	; total no carry: 22 cycles
 	rts		; total with carry: 32 cycles
	
subOffset
	lda 	SCRN_LSB        ;3
	sty 	SCRN_LSB       	;3
	clc              	;2     ; clear the carry
	sbc 	SCRN_LSB       	;3     ; sub from LSB
	sta 	SCRN_LSB       	;3     ; store result in LSB

	lda 	SCRN_MSB       	;3
	sec
	sbc 	#0       	;2     ; add carry to MSB
	sta 	SCRN_MSB       	;3     ; store MSB
	rts      ;total: 22 cycleS
	
;;; ----- DRAWING ROUTINES
	
drawChar:
	ldx	CURR_SPRITE
	ldy	#$00    ; draw 1st char
	jsr	draw
	inx      	; draw 2nd char
	ldy	#$16
	jsr	draw
	inx 	 	; draw 3rd char
	ldy	#$01
	jsr	draw
	inx   	   	; draw 4th char
	ldy 	#$17
	jsr 	draw
	
; needs sprite in X 
; needs offset in y
; needs character color in a
draw:
	lda	sprite_char_color
	sta	(CLRM_LSB),y
	txa
	sta 	(SCRN_LSB),y
	rts

erase:	
	ldx	#32     ; load blank
	ldy	#0
	jsr 	draw
	ldy 	#1
	jsr 	draw
	ldy 	#22
	jsr 	draw
	ldy 	#23
	jsr 	draw
	rts
	
;;; SUBROUTINES

startFrame:	
	lda	#$00
	sta	FRAME	
frame:	
	lda	RASTER		; raster beam line number
	cmp	#$0		; top of the screen
	bne	frame
	inc	FRAME		; increase frame counter
	lda	FRAME
	cmp	#$40		; add delay
	bne	frame
	rts

;;; ---- SPRITES AND STUFF
	
sprite_char_color:
	BYTE	$09,$09,$09,$0f
	
sprite:
	;;  sprite facing forward
	BYTE	21,85,118,89,89,30,90,85
	BYTE	7,31,31,31,127,85,4,4
	BYTE	84,84,164,152,152,172,164,85
	BYTE	208,100,100,220,253,85,16,16

	;; sprite facing backward
	BYTE	21,85,118,89,89,30,90,85
	BYTE	7,31,31,31,127,85,4,4
	BYTE	84,84,164,152,152,172,164,85
	BYTE	208,100,100,220,253,85,16,16


	;; sprite to the side
	BYTE	21,85,117,85,85,85,85,21
	BYTE	7,31,31,127,127,85,4,4
	BYTE	84,85,85,85,85,85,85,84
	BYTE	208,244,244,253,253,85,16,16
