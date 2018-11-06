;;; ----- MOVEMENT ROUTINES
check_movement:
	ldy	#$00		; top left corner
	lda	(SPRITE_LSB),y
	cmp	#$20
	bne	invalid_movement
	ldy	#$01		; top right corner
	lda	(SPRITE_LSB),y
	cmp	#$20
	bne	invalid_movement
	ldy	#$16		; bottom left corner
	lda	(SPRITE_LSB),y
	cmp	#$20
	bne	invalid_movement
	ldy	#$17		; bottom right corner
	lda	(SPRITE_LSB),y
	cmp	#$20
	bne	invalid_movement
	;; valid movement
	rts
invalid_movement:
	;; restore previous
	lda	PREV_SPRITE_LSB
	sta	SPRITE_LSB
	lda	PREV_SPRITE_MSB
	sta	SPRITE_MSB
	lda	PREV_SPRITE_CLR_LSB
	sta	SPRITE_CLR_LSB
	lda	PREV_SPRITE_CLR_MSB
	sta	SPRITE_CLR_MSB
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
	rts

drawPlayerArea:
	draw_char CURR_SPRITE, CURR_CLR, SPRITE_CLR_LSB, SPRITE_LSB

	draw_char TREE_SPRITE, TREE_CLR, SPRITE_CLR_LSB, SPRITE_LSB
	rts

erase:	
	ldx	#32     ; load blank
	ldy	#$00
	draw_sprite CURR_CLR, SPRITE_CLR_LSB, SPRITE_LSB
	ldy #$01
	draw_sprite CURR_CLR, SPRITE_CLR_LSB, SPRITE_LSB
	ldy #$16
	draw_sprite CURR_CLR, SPRITE_CLR_LSB, SPRITE_LSB
	ldy #$17
	draw_sprite CURR_CLR, SPRITE_CLR_LSB, SPRITE_LSB
	rts

; needs move increment in Y register
addSpriteOffset:
	tya                     ; move increment in acumulator
  clc                     ; clear the carry
  adc SPRITE_LSB    	    ; add to LSB
  sta SPRITE_LSB	        ; store result in LSB

	tya			
	clc			
	adc	SPRITE_CLR_LSB
	sta	SPRITE_CLR_LSB
	
	bcc	addOffset_no_carry

	inc	SPRITE_MSB
	inc	SPRITE_CLR_MSB
addOffset_no_carry:
 	rts

subSpriteOffset:
	Lda 	SPRITE_LSB    
	sty 	SPRITE_LSB   	
	sec		                ; clear the borrow
	sbc 	SPRITE_LSB    	; sub from LSB
	sta 	SPRITE_LSB    	; store result in LSB

	lda	SPRITE_CLR_LSB
	sty	SPRITE_CLR_LSB
	sec	
	sbc	SPRITE_CLR_LSB
	sta	SPRITE_CLR_LSB

	bcs	subOffset_no_borrow

	dec	SPRITE_MSB
	dec	SPRITE_CLR_MSB
subOffset_no_borrow:
	rts 