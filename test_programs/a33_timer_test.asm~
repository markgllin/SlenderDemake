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
	
CURR_SPRITE = $08	; stores the starting character for current sprite
FRAME	    = $09	; frame counter for delays
CURR_CLR    = $0a	; stores the current character colour

PREV_SCRN_LSB = $10	
PREV_SCRN_MSB = $11
PREV_CLRM_LSB = $14
PREV_CLRM_MSB = $15
	
	
;;; ---- CONSTANTS
CHAR_FORWARD      = #$00	; character facing forward
CHAR_BCKWARD      = #$04	; character facing backward
CHAR_RIGHT        = #$08	; character facing to the right
CHAR_LEFT         = #$0c	; character facing to the left
TREE1             = #$10	

SPRITE_CHAR_COLOR = #$09 	; multi-colour white
TREE_CHAR_COLOR   = #$0d	; multi-colour green
	
	processor	6502
	org		$1001

	dc.w	end
	dc.w	1234
	dc.b	$9e, " 4110", 0
end:	dc.w	0

start:
	lda	#14	; border blue, screen black (ref p. 265)
	sta 	SCR_C
	lda	#112	; yellow = first byte 7 (ref p. 264)
			; 112 = 0111 0000 where 111 = 7
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
	
	;; now, load the sprites into memory
  	ldx	#0
load:	lda	sprite,X
  	sta	CHAR_MEM,X	
  	inx
  	cpx	#160
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
	
draw_tree:
	lda	#$e6		; offset tree
	sta	SCRN_LSB
	sta	CLRM_LSB
	
	lda	#TREE_CHAR_COLOR
	sta	CURR_CLR
	lda	#TREE1
	sta	CURR_SPRITE
	jsr	drawChar

	lda	#$00		; reset offset
	sta	SCRN_LSB
	sta	CLRM_LSB

draw_sprite:
	lda	#SPRITE_CHAR_COLOR
	sta	CURR_CLR
	lda	#CHAR_FORWARD
	sta	CURR_SPRITE
	jsr	drawChar
	
;;; ----- INPUT
input
	jsr 	startFrame
	lda 	$00c5   ; current key pressed (pg 172)
	cmp 	#9      ;w
	beq 	up
	cmp 	#17     ;a
	beq 	left    
	cmp 	#41     ;s
	beq 	down
	cmp 	#18     ;d
	beq 	right
	jmp 	input
up:
	jsr	erase
	ldy 	#22
	jsr 	subOffset
	
	lda	#CHAR_BCKWARD
	sta	CURR_SPRITE
	jmp 	doneInput
down:
	;; check valid movement
	;; ldy	#$2c
	;; lda	(SCRN_LSB),y
	;; cmp	#$20
	;; bne	doneInput
	;; iny
	;; lda	(SCRN_LSB),y
	;; cmp	#$20
	;; bne	doneInput
	
	;; valid movement
	jsr 	erase
	ldy 	#$16
	jsr 	addOffset
	
	lda	#CHAR_FORWARD
	sta	CURR_SPRITE
	jmp 	doneInput
left:
	jsr 	erase
	ldy 	#1
	jsr 	subOffset

	lda	#CHAR_LEFT
	sta	CURR_SPRITE
	jmp 	doneInput
right:
	;; check valid movement
	;; ldy	#2
	;; lda	(SCRN_LSB),y
	;; cmp	#$20
	;; bne	doneInput
	;; ldy	#$18
	;; lda	(SCRN_LSB),y
	;; cmp	#$20
	;; bne	doneInput

	;; movement is valid
	jsr 	erase
	ldy 	#1
	jsr 	addOffset

	lda	#CHAR_RIGHT
	sta	CURR_SPRITE
doneInput:
	jsr	check_movement
	jsr	drawChar
	jmp	input

;;; ----- MOVEMENT ROUTINES
check_movement:
	ldy	#$00		; top left corner
	lda	(SCRN_LSB),y
	cmp	#$20
	bne	invalid_movement
	ldy	#$01		; top right corner
	lda	(SCRN_LSB),y
	cmp	#$20
	bne	invalid_movement
	ldy	#$16		; bottom left corner
	lda	(SCRN_LSB),y
	cmp	#$20
	bne	invalid_movement
	ldy	#$17		; bottom right corner
	lda	(SCRN_LSB),y
	cmp	#$20
	bne	invalid_movement
	;; valid movement
	rts
invalid_movement:
	;; restore previous
	lda	PREV_SCRN_LSB
	sta	SCRN_LSB
	lda	PREV_SCRN_MSB
	sta	SCRN_MSB
	lda	PREV_CLRM_LSB
	sta	CLRM_LSB
	lda	PREV_CLRM_MSB
	sta	CLRM_MSB
	rts
	
save_previous:
	lda	SCRN_LSB
	sta	PREV_SCRN_LSB
	lda	SCRN_MSB
	sta	PREV_SCRN_MSB
	lda	CLRM_LSB
	sta	PREV_CLRM_LSB
	lda	CLRM_MSB
	sta	PREV_CLRM_MSB
	rts

; needs move increment in Y register
addOffset:
	jsr	save_previous
	tya                     ;2      ; move increment in acumulator
  	clc                     ;2      ; clear the carry
  	adc 	SCRN_LSB    	;3      ; add to LSB
  	sta 	SCRN_LSB	;3      ; store result in LSB

	tya			;2
	clc			;2
	adc	CLRM_LSB	;3
	sta	CLRM_LSB	;3
	
	bcc	addOffset_no_carry ;~2

	inc	SCRN_MSB	;5
	inc	CLRM_MSB	;5

addOffset_no_carry:	; total no carry: 22 cycles
 	rts		; total with carry: 32 cycles
	
subOffset:
	jsr	save_previous
	Lda 	SCRN_LSB    	;3
	sty 	SCRN_LSB   	;3
	sec			;2     ; clear the borrow
	sbc 	SCRN_LSB    	;3     ; sub from LSB
	sta 	SCRN_LSB    	;3     ; store result in LSB

	lda	CLRM_LSB	;3
	sty	CLRM_LSB	;3
	sec			;2
	sbc	CLRM_LSB	;3
	sta	CLRM_LSB	;3

	bcs	subOffset_no_borrow ;~2

	dec	SCRN_MSB    ;3
	dec	CLRM_MSB	;3
	
subOffset_no_borrow:	; total without borrow: 30
			; total with borrow: 36
	rts      
	
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
draw:
	lda	CURR_CLR
	sta	(CLRM_LSB),y
	txa
	sta 	(SCRN_LSB),y
	rts

erase:	
	ldx	#32     ; load blank
	ldy	#$00
	jsr 	draw
	ldy 	#$01
	jsr 	draw
	ldy 	#$16
	jsr 	draw
	ldy 	#$17
	jsr 	draw
	rts
	
;;; SUBROUTINES

startFrame:	
	lda	#$00
	sta	FRAME	
frame:	
	lda	RASTER		; raster beam line number
	bne	frame
	inc	FRAME		; increase frame counter
	lda	FRAME
	cmp	#$15		; add delay
	bne	frame
	rts

;;; ---- SPRITES AND STUFF
	
sprite:
	;;  sprite facing forward
	BYTE	21,85,118,89,89,30,90,85
	BYTE	7,31,31,31,127,85,4,4
	BYTE	84,84,164,152,152,172,164,85
	BYTE	208,100,100,220,253,85,16,16

	;; sprite facing backward
	BYTE	21,85,117,85,85,85,85,21
	BYTE	7,31,31,127,127,85,4,4
	BYTE	84,85,85,85,85,85,85,84
	BYTE	208,244,244,253,253,85,16,16
	
	;; sprite facing to the right
	BYTE	21,85,117,94,86,87,22,85
	BYTE	7,31,31,31,127,85,16,16
	BYTE	84,84,164,100,105,164,164,80
	BYTE	208,244,217,217,244,84,16,16
	
	;; sprite facing to the left
	BYTE	21,21,26,25,105,26,26,5
	BYTE	7,31,103,103,31,21,4,4
	BYTE	84,85,85,149,149,213,148,85
	BYTE	208,244,244,244,253,85,4,4
	
tree1:
	BYTE	1,1,7,1,7,30,7,30
	BYTE	26,122,30,122,85,1,1,5
	BYTE	64,64,144,64,144,164,144,164
	BYTE	164,169,164,169,85,64,64,80
