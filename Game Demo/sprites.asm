;;; ----- DRAWING ROUTINES

place_letter:
	lda	LFSR
	jsr	random

	sta	LETTER_LSB
	sta	LETTER_CLR_LSB	

	ldy #$0
	lda (LETTER_LSB),y
	cmp #PATH
	bne place_letter

	ldy #$1
	lda (LETTER_LSB),y
	cmp #PATH
	bne place_letter

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

erase:
	ldx #PATH			; load blank
	ldy	#$00
	draw_sprite CURR_CLR, SPRITE_CLR_LSB, SPRITE_LSB
	ldy	#$01
	draw_sprite CURR_CLR, SPRITE_CLR_LSB, SPRITE_LSB	
	ldy	#$16
	draw_sprite CURR_CLR, SPRITE_CLR_LSB, SPRITE_LSB	
	ldy	#$17
	draw_sprite CURR_CLR, SPRITE_CLR_LSB, SPRITE_LSB	
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

letter:	
	BYTE	0,15,11,13,14,15,15,0
	BYTE	0,240,208,176,112,240,240,0
