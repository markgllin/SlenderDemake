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
TREE_ROW_MAP				= $12
TEMP = $13
TEMP_TREE_ADDRESS = $11

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

	processor 6502

  org $1001
  DC.W end
  DC.W 1234
  DC.B $9e, " 4110", 0
end
  dc.w 0

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


	; need to update this to use relative offsets instead of absolute
  lda #$aa
	sta TREE_ROW_MAP
	lda #$0
	sta TEMP_TREE_ADDRESS		;tree offset
	jsr draw_tree_row

  lda #$aa
	sta TREE_ROW_MAP
	lda #$2c
	sta TEMP_TREE_ADDRESS		;tree offset
	jsr draw_tree_row

  lda #$aa
	sta TREE_ROW_MAP
	lda #$58
	sta TEMP_TREE_ADDRESS		;tree offset
	jsr draw_tree_row

  lda #$e0
	sta TREE_ROW_MAP
	lda #$84
	sta TEMP_TREE_ADDRESS		;tree offset
	jsr draw_tree_row

  lda #$aa
	sta TREE_ROW_MAP
	lda #$b0
	sta TEMP_TREE_ADDRESS		;tree offset
	jsr draw_tree_row

  lda #$aa
	sta TREE_ROW_MAP
	lda #$dc
	sta TEMP_TREE_ADDRESS		;tree offset
	jsr draw_tree_row
loop
  jmp loop

draw_tree_row:
	lda #0
	sta TEMP ; counter
draw_row:
	lda #11
	cmp TEMP
	beq done_drawing_trees

	inc TEMP
	ror TREE_ROW_MAP
	bcc no_trees
	lda TEMP_TREE_ADDRESS
	jsr draw_tree
no_trees
	inc TEMP_TREE_ADDRESS
	inc TEMP_TREE_ADDRESS
	jmp draw_row
done_drawing_trees:
	rts
  
draw_tree:
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
	sta	(CLRM_LSB),y
	txa
	sta 	(SCRN_LSB),y
	rts

startFrame	
  lda	#$00
	sta	FRAME	
frame	
  lda	$9004		; raster beam line number
	cmp	#$0		; top of the screen
	bne frame
	inc	FRAME		; increase frame counter
	lda	FRAME
	cmp	#$0		; add delay
	bne	frame
  rts

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