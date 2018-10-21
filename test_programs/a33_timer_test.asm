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

NUMBERS_ADDRESS = $1d80		; where numbers start in custom charset
	
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

NUMBERS           = #$30	; number 0
	
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

	;; copy the numbers from memory
	;; a.k.a copy starting from $8000 + ($30 * 8) = $8000 + $180 = $8180
	;; Copy all 10 characters: 10 * 8 = 80 = $50 bytes to copy
	ldx	#$0
copy:	lda	$8180,X		; copy the source to the destination
	sta	$1d80,X		
	inx
	cpx	#$50		; copy characters 0-9
	bne	copy
	
	lda	#255		; custom character set
	sta	$9005
	
init_numbers:
	lda	#$00
	sta	SCRN_LSB
	sta	CLRM_LSB
	lda	#$1e
	sta	SCRN_MSB
	lda	#$96
	sta	CLRM_MSB
	
	ldy	#$0
	
init_loop:	
	lda	#$30			; number 0
	sta	(SCRN_LSB),y		; position
	lda	#$01
	sta	(CLRM_LSB),y
	iny
	cpy	#$04
	bne	init_loop
	
	rts
