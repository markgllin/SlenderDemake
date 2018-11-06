	processor	6502
	org		$1001

	dc.w	end
	dc.w	1234
	dc.b	$9e, " 4110", 0
end:	dc.w	0


	INCLUDE	"constants.asm"
	INCLUDE "zero_page.asm"

	;; set up the interrupts
	jsr	timer2_IRQ	
start:
	lda	#14	; border blue, screen black (ref p. 265)
	sta 	SCR_C
	lda	#112	; yellow = first byte 7 (ref p. 264)
			; 112 = 0111 0000 where 111 = 7
	sta	AUX_C
	lda	#01	; white characters
	sta	CHR_C

	lda	#255		; custom character set
	sta	$9005

	;; load zeros into the "0" character of our custom charset
	ldx	#$00
	lda	#$00
copy_blank:
	sta	$1c00,X
	inx
	cpx	#$08
	bne	copy_blank
	
	lda	#$00 		; used to be 20 - now 0 because easier comparisons
	ldx	#$00	
clear_loop:			; clear the screen
	sta	SCRN_MEM1,X
	sta	SCRN_MEM2,X
	inx
	bne	clear_loop

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

	INCLUDE	"movement.asm"
	INCLUDE	"interrupts.asm"
	INCLUDE "sprites.asm"
