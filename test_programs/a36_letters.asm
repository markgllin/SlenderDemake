;;; ---- ADDRESSES
AUX_C     = $900e	; bits 4-7: auxillary colour
SCR_C     = $900f	; bits 0-2: border color 
                        ; bits 4-7: background color
CHR_C     = $0286	; character color (dec: 646)

COLOR_MEM = $9600	; start of colour memory 
SCRN_MEM1 = $1e00	; start of screen memory
SCRN_MEM2 = $1f00	; middle of screen memory
CHAR_MEM  = $1c00	; start of character memory

SCRN_V    = $9001	; vertical origin of the screen
ROWS	  = $9003	; bits 1-6: number of rows (ref: p 175)
RASTER	  = $9004

;; The IRQ vector is the location (ISR) to jump when an interrupt happens
IRQ_L        = $0314		; low byte of IRQ vector 
IRQ_H        = $0315		; high byte of IRQ vector 
OLD_IRQ      = $eabf
	
VIA_CONTROL  = $911b
VIA_FLAGS    = $911d		; reference: page 218
VIA_ENABLE   = $911e

TIMER1_LOC   = $9114		; timer 1 low order counter
TIMER1_HOC   = $9115		; timer 1 high order counter
TIMER1_LOL   = $9116		; timer 1 low order latch
TIMER1_HOL   = $9117		; timer 1 high order latch
	
TIMER2_L     = $9118		; timer 2 low order byte
TIMER2_H     = $9119		; timer 2 high order byte

;;; CUSTOM CHARSET ADDRESSES
SPACE_ADDRESS   = $1c00   	; where the space character starts
SPRITE_ADDRESS  = $1c08		; where the sprites start
NUMBERS_ADDRESS = $1cb8		; where numbers start in custom charset
	
;;; ---- ZERO PAGE
SCRN_LSB    = $00	; LSB of screen memory address
SCRN_MSB    = $01	; MSB Of screen memory address	
CLRM_LSB    = $04	; LSB of colour memory address
CLRM_MSB    = $05	; MSB Of colour memory address

GAME_STATUS = $07	; if this is 0, end game
	
CURR_SPRITE = $08	; stores the starting character for current sprite
FRAME	    = $09	; frame counter for delays
CURR_CLR    = $0a	; stores the current character colour
TIMER_CTR   = $0b	; timer counter
NUM_WRAPS   = $0c	; used to figure out end game condition
	                ; basically, counts the number of times the numbers wrap per decrement 
	                ; If this reaches 3, then FULL WRAP AROUND so end game 
SPRITE_X = $0d
SPRITE_Y = $0e
SPRITE_PREV_X = $0f
SPRITE_PREV_Y = $10	
	
	
;; save the previous position of sprite incase invalid movement 
PREV_SPRITE_LSB     = $11	
PREV_SPRITE_MSB     = $12
PREV_SPRITE_CLR_LSB = $15
PREV_SPRITE_CLR_MSB = $16

;; current / proposed movement of sprite 
SPRITE_LSB	 = $18
SPRITE_MSB       = $19
SPRITE_CLR_LSB   = $1a
SPRITE_CLR_MSB   = $1b

LETTER_LSB 	 = $1e
LETTER_MSB	 = $1f
LETTER_CLR_LSB   = $20
LETTER_CLR_MSB	 = $21	

SCORE_LSB	 = $22
SCORE_MSB	 = $23

LFSR 		 = $24	
	
;;; ---- CONSTANTS
SPACE             = #$00	; @
CHAR_FORWARD      = #$01	; A = character facing forward
CHAR_BCKWARD      = #$05	; E = character facing backward
CHAR_RIGHT        = #$09	; I = character facing to the right
CHAR_LEFT         = #$0d	; M = character facing to the left
TREE1             = #$11	; Q = tree sprite  
ITEM_LETTER	  = #$15 	; U = letter sprite
NUM_ZERO	  = #$17	; W = start of number 0
NUM_NINE	  = #$20	; SPACE = start of number 9 

SPRITE_CHAR_COLOR = #$09 	; multi-colour white
TREE_CHAR_COLOR   = #$0d	; multi-colour green

;; The timer runs at 1MHz so that means 1,000,000 cycles per second
;; Hence, we need to wait 1,000,000 = $000F 4240 cycles to wait a single second
;; That is, wait $f424 a total of $10 = 16 times.
SECOND_H	  = #$f4	; high byte of $f906
SECOND_L	  = #$24	; low  byte of $f906
NUM_SEC		  = #$11	; 1 MORE THAN how many ^ it takes for a single second

	processor	6502
	org		$1001

	dc.w	end
	dc.w	1234
	dc.b	$9e, " 4110", 0
end:	dc.w	0

	;; set up the new IRQ vector for timer 2
timer2_IRQ:
	lda	VIA_CONTROL
	and	#$df	 	; set timer 2 to one-shot-mode
	sta	VIA_CONTROL

	lda	#$a0 		; enable timer 2
	sta 	VIA_ENABLE
	
	sei			; disable interrupts

	lda	#<isr_update_timer	; get low byte of ISR address
				; reference for this notation: page 204
	sta	IRQ_L
	lda	#>isr_update_timer	; get high byte of ISR address
	sta	IRQ_H

	cli			; enable interrupts again
	
start:
	lda	#14	; border blue, screen black (ref p. 265)
	sta 	SCR_C
	lda	#112	; yellow = first byte 7 (ref p. 264)
			; 112 = 0111 0000 where 111 = 7
	sta	AUX_C
	lda	#01	; white characters
	sta	CHR_C

	lda	#$00 		; used to be 20 - now 0 because easier comparisons
	ldx	#$00	
clear_loop:			; clear the screen
	sta	SCRN_MEM1,X
	sta	SCRN_MEM2,X
	inx
	bne	clear_loop

	lda	#255		; custom character set
	sta	$9005

	;; copy the normal BLANK character (20) to the (00) character
	ldx	#$00
copy_blank:
	lda	$1d00,X		; space character
	sta	$1c00,X
	inx
	cpx	#$08
	bne	copy_blank
	
	;; now, load the sprites into memory
  	ldx	#00
copy_sprites:
	lda	sprite,X
  	sta	SPRITE_ADDRESS,X	
  	inx
  	cpx	#176
  	bne	copy_sprites

	;; copy the numbers from memory
	;; a.k.a copy starting from $8000 + ($30 * 8) = $8000 + $180 = $8180
	;; Copy all 10 characters: 10 * 8 = 80 = $50 bytes to copy
	ldx	#$0
copy_numbers:
	lda	$8180,X			; copy the source to the destination
	sta	NUMBERS_ADDRESS,X	; end of sprites
	inx
	cpx	#$50		; copy characters 0-9
	bne	copy_numbers
	
init_all_the_things:	
	;; store memory addresses for calculations later  
	lda 	#$00            ; load LSB
	sta 	SCRN_LSB
	sta	SPRITE_LSB
	sta	CLRM_LSB
	sta	SPRITE_CLR_LSB

	lda	#$12		
	sta	SCORE_LSB
	
	lda 	#$1e            ; load MSB
	sta	SCRN_MSB
	sta	SPRITE_MSB
	sta	SCORE_MSB
	lda	#$1f
	sta	LETTER_MSB

	lda	#$96		
	sta	CLRM_MSB
	sta	SPRITE_CLR_MSB
	lda	#$97
	sta	LETTER_CLR_MSB
	
	;; init all the other things
	lda	#$00
	sta	NUM_WRAPS
	lda	#$01
	sta	SPRITE_Y
	lda	#$0a
	sta	SPRITE_X
	lda	#$ff
	sta	GAME_STATUS
	lda 	#39		; init the SEEEED for RNG
	sta 	LFSR
	
	;; initialize the timer to 0300
	ldy	#$0
init_timer_loop:	
	lda	#NUM_ZERO 		; number 0
	sta	(SCRN_LSB),y		; position
	lda	#$01			; font color = white
	sta	(CLRM_LSB),y
	iny
	cpy	#$04
	bne	init_timer_loop

	ldy	#$01
	lda	#NUM_ZERO + 3		; number 3
	sta	(SCRN_LSB),y
	lda	#NUM_SEC
	sta	TIMER_CTR

	;; initialize the score
	ldy	#$12
init_score_loop:
	lda	#NUM_ZERO
	sta	(SCRN_LSB),y
	lda	#$01		; font color = white
	sta	(CLRM_LSB),y
	iny
	cpy	#$16
	bne	init_score_loop
	
draw_tree:
	lda	#$e6		; offset tree
	sta	SPRITE_LSB
	sta	SPRITE_CLR_LSB
	
	lda	#TREE_CHAR_COLOR
	sta	CURR_CLR
	lda	#TREE1
	sta	CURR_SPRITE
	jsr	drawChar
	
draw_sprite:
	lda	#$20		; offset sprite
	sta	SPRITE_LSB
	sta	SPRITE_CLR_LSB
	
	lda	#SPRITE_CHAR_COLOR
	sta	CURR_CLR
	lda	#CHAR_FORWARD
	sta	CURR_SPRITE
	jsr	drawChar

	jsr 	place_letter
	
start_timer:
	lda	SECOND_L
	sta	TIMER2_L
	lda	SECOND_H
	sta	TIMER2_H	; STARTS the timer
	
;;; ----- INPUT
input:
	;; check game status FIRST
	lda	GAME_STATUS
	beq	end_game

	;; not end game so continue
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
	dec	SPRITE_Y

	lda	#CHAR_BCKWARD
	sta	CURR_SPRITE
	
	jmp 	doneInput
down:	
	jsr 	erase
	ldy 	#$16
	jsr 	addOffset
	inc	SPRITE_Y	
	
	lda	#CHAR_FORWARD
	sta	CURR_SPRITE
	jmp 	doneInput
left:
	jsr 	erase
	ldy 	#1
	jsr 	subOffset
	dec	SPRITE_X

	lda	#CHAR_LEFT
	sta	CURR_SPRITE
	jmp 	doneInput
right:
	jsr 	erase
	ldy 	#1
	jsr 	addOffset
	inc	SPRITE_X
	
	lda	#CHAR_RIGHT
	sta	CURR_SPRITE
doneInput:
	jsr	check_movement
	jsr	drawChar
	jmp	input

;;; ----- END GAME

end_game:
	jmp	end_game
	
;;; ----- MOVEMENT ROUTINES
check_movement:
	;; collision checks
	ldy	#$00		; top left corner
	lda	(SPRITE_LSB),y
	bne	collision
	ldy	#$01		; top right corner
	lda	(SPRITE_LSB),y
	bne	collision
	ldy	#$16		; bottom left corner
	lda	(SPRITE_LSB),y
	bne	collision
	ldy	#$17		; bottom right corner
	lda	(SPRITE_LSB),y
	bne	collision

	;; boundary checks
	ldx	SPRITE_X
	cpx	#$ff		; exceed left
	beq	invalid_movement
	cpx	#$15		; exceed right
	beq	invalid_movement
	ldy	SPRITE_Y
	cpy	#$16		; exceed bottom
	beq	invalid_movement
	
	;; no collisions 
	rts
collision:
	cmp	#ITEM_LETTER
	beq	letter_found
	cmp	#ITEM_LETTER + 1
	bne	invalid_movement
letter_found:	
	;; found a letter!
	;; so update the score
	ldy	#$01		; second digit from the left
	lda	(SCORE_LSB),y
	cmp	#NUM_NINE
	bne	score_no_wrap

	;; score wraps, so do that
	lda	#NUM_ZERO
	sta	(SCORE_LSB),y
	
	dey
	lda	(SCORE_LSB),y
	clc
	adc	#$01
	sta	(SCORE_LSB),y
	jmp	done_score
	
score_no_wrap:
	clc
	adc	#$01
	sta	(SCORE_LSB),y

done_score:	
	;; and erase the letter
	lda	#$00
	ldy	#$00
	sta	(LETTER_LSB),y
	iny
	sta	(LETTER_LSB),y

	;; new letter!
	jsr	place_letter
	
	rts
	
invalid_movement:
	;; restore previous position
	lda	PREV_SPRITE_LSB
	sta	SPRITE_LSB
	lda	PREV_SPRITE_MSB
	sta	SPRITE_MSB
	lda	PREV_SPRITE_CLR_LSB
	sta	SPRITE_CLR_LSB
	lda	PREV_SPRITE_CLR_MSB
	sta	SPRITE_CLR_MSB

	lda	SPRITE_PREV_X
	sta	SPRITE_X	
	lda	SPRITE_PREV_Y
	sta	SPRITE_Y
	rts
	
save_previous:
	lda	SPRITE_LSB
	sta	PREV_SPRITE_LSB
	lda	SPRITE_MSB
	sta	PREV_SPRITE_MSB
	lda	SPRITE_CLR_LSB
	sta	PREV_SPRITE_CLR_LSB
	lda	SPRITE_CLR_MSB
	sta	PREV_SPRITE_CLR_MSB

	lda	SPRITE_X
	sta	SPRITE_PREV_X
	lda	SPRITE_Y
	sta	SPRITE_PREV_Y
	
	rts

; needs move increment in Y register
addOffset:
	jsr	save_previous
	tya                     ;2      ; move increment in acumulator
  	clc                     ;2      ; clear the carry
  	adc 	SPRITE_LSB    	;3      ; add to LSB
  	sta 	SPRITE_LSB	;3      ; store result in LSB
	
	tya			;2
	clc			;2
	adc	SPRITE_CLR_LSB	;3
	sta	SPRITE_CLR_LSB	;3
	
	bcc	addOffset_no_carry ;~2

	inc	SPRITE_MSB	;5
	inc	SPRITE_CLR_MSB	;5

addOffset_no_carry:	; total no carry: 22 cycles
 	rts		; total with carry: 32 cycles
	
subOffset:
	jsr	save_previous
	Lda 	SPRITE_LSB    	;3
	sty 	SPRITE_LSB   	;3
	sec			;2     ; clear the borrow
	sbc 	SPRITE_LSB    	;3     ; sub from LSB
	sta 	SPRITE_LSB    	;3     ; store result in LSB

	lda	SPRITE_CLR_LSB	;3
	sty	SPRITE_CLR_LSB	;3
	sec			;2
	sbc	SPRITE_CLR_LSB	;3
	sta	SPRITE_CLR_LSB	;3

	bcs	subOffset_no_borrow ;~2

	dec	SPRITE_MSB    ;3
	dec	SPRITE_CLR_MSB	;3
	
subOffset_no_borrow:	; total without borrow: 30
			; total with borrow: 36
	rts      
	
;;; ----- DRAWING ROUTINES

place_letter:
	lda	LFSR
	jsr	random

	sta	LETTER_LSB
	sta	LETTER_CLR_LSB	

	ldy	#$0
	lda	#ITEM_LETTER
	sta	(LETTER_LSB),y
	lda	#$01
	sta	(LETTER_CLR_LSB),y

	iny
	lda	#ITEM_LETTER + 1
	sta	(LETTER_LSB),y
	lda	#$01
	sta	(LETTER_CLR_LSB),y
	
	rts
	
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
	sta	(SPRITE_CLR_LSB),y
	txa
	sta 	(SPRITE_LSB),y
	rts

erase:	
	ldx	#0     ; load blank
	ldy	#$00
	jsr 	draw
	ldy 	#$01
	jsr 	draw
	ldy 	#$16
	jsr 	draw
	ldy 	#$17
	jsr 	draw
	rts
	
;;; ---- FRAME SUBROUTINES

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

;;; ---- RANDOM NUMERS
random:	
	ldy	LFSR
	lsr 	LFSR                    ; 00010011 1  = 19
	lsr 	LFSR                    ; 00001001 1  = 9
	eor 	LFSR    ; 6th tap   ; 00101110 1  = 46
	lsr 	LFSR                    ; 00010111 1
	eor 	LFSR    ; 5th tap   ; 00110000 1
	lsr 	LFSR                    ; 00011000 0
	eor 	LFSR    ; 4th tap   ; 00111111 0
	and 	#1                  ; 00000001 0
	sty 	LFSR
	lsr 	LFSR
	clc
	ror
	ror                      ; 10000000 1
	ora 	LFSR                 ; 10010011 1
	sta 	LFSR
	rts

	
;;; ---- INTERRUPTS

isr_update_timer:
	pha			; save old A
	txa
	pha			; save old X
	tya
	pha			; save old Y

	;; check that the interrupt is happening from timer 2
	lda	VIA_FLAGS
	and	#$20		; check TIMER2 bit ($20 = 0010 0000)
	beq	isr_done_update	; TIMER2 bit is not set so different interrupt

	;; check end game condition in case it's already end game
	lda	GAME_STATUS
	beq	isr_done_update

	;; correct timer interrupt so do the thing
	;; start by restarting the timer 
	lda	SECOND_L
	sta	TIMER2_L	
	lda	SECOND_H
	sta	TIMER2_H	; STARTS the timer and clears the interrupt request

	dec	TIMER_CTR
	lda	TIMER_CTR
	bne	isr_done_update ; counter is not zero

	;; a second has passed
	lda	#NUM_SEC	; reload counter
	sta	TIMER_CTR

isr_first_digit:		; check the seconds digit
	ldy	#$03
	lda	(SCRN_LSB),y
	cmp	#NUM_ZERO
	beq	isr_first_wrap_around

	sec
	sbc	#$01	
	sta	(SCRN_LSB),y
	jmp	isr_done_update
	
isr_first_wrap_around:
	inc	NUM_WRAPS
	
	lda	#NUM_NINE
	sta	(SCRN_LSB),y

	ldy	#$02		; check second digit
	lda	(SCRN_LSB),y
	cmp	#NUM_ZERO
	beq	isr_second_wrap_around

	sec
	sbc	#$01
	sta	(SCRN_LSB),y
	jmp	isr_done_update
	
isr_second_wrap_around:	
	inc	NUM_WRAPS
	
	lda	#NUM_NINE
	sta	(SCRN_LSB),y
	
	ldy	#$01		; check third digit
	lda	(SCRN_LSB),y
	cmp	#NUM_ZERO
	beq	isr_third_wrap_around

	sec
	sbc	#$01
	sta	(SCRN_LSB),y
	jmp	isr_done_update

isr_third_wrap_around:
	inc	NUM_WRAPS
	lda	NUM_WRAPS
	cmp	#$03
	beq	isr_trigger_end_game

	lda	#$00		; NOT end game so reset wraps
	sta	NUM_WRAPS	
	lda	#NUM_NINE
	sta	(SCRN_LSB),y
	jmp	isr_done_update

isr_trigger_end_game:
	;; reset timer to ZERO since wrap around for first
	;; two digits already happened
	lda	#NUM_ZERO
	ldy	#02
	sta	(SCRN_LSB),y
	ldy	#03
	sta	(SCRN_LSB),y
	
	lda	#$0
	sta	GAME_STATUS
	
isr_done_update:
	pla
	tay			; restore old Y
	pla
	tax			; restore old X
	pla			; restore old A
	
	jmp	OLD_IRQ


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

letter:	
	BYTE	0,15,11,13,14,15,15,0
	BYTE	0,240,208,176,112,240,240,0
