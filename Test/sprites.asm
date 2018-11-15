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
	erase_char #PATH, CURR_CLR, SPRITE_CLR_LSB, SPRITE_LSB
	;jsr erase_env
	rts

; erase_env: subroutine
; .draw_NW_tree
; 	update_tree_addr #46, SPRITE_LSB, SPRITE_MSB, SPRITE_CLR_LSB, SPRITE_CLR_MSB, subOffset
;   beq .draw_N_tree
; 	erase_char #PATH, TREE_CLR, TREE_CLR_LSB, TREE_LSB
; .draw_N_tree
; 	update_tree_addr #2, TREE_LSB, TREE_MSB, TREE_CLR_LSB, TREE_CLR_MSB, addOffset
; 	beq .draw_NE_tree
; 	erase_char #PATH, TREE_CLR, TREE_CLR_LSB, TREE_LSB
; .draw_NE_tree
; 	update_tree_addr #2, TREE_LSB, TREE_MSB, TREE_CLR_LSB, TREE_CLR_MSB, addOffset
;   beq .draw_W_tree
; 	erase_char #PATH, TREE_CLR, TREE_CLR_LSB, TREE_LSB
; .draw_W_tree
; 	update_tree_addr #40, TREE_LSB, TREE_MSB, TREE_CLR_LSB, TREE_CLR_MSB, addOffset
;   beq .draw_E_tree
; 	erase_char #PATH, TREE_CLR, TREE_CLR_LSB, TREE_LSB
; .draw_E_tree
; 	update_tree_addr #4, TREE_LSB, TREE_MSB, TREE_CLR_LSB, TREE_CLR_MSB, addOffset
;   beq .draw_SW_tree
; 	erase_char #PATH, TREE_CLR, TREE_CLR_LSB, TREE_LSB
; .draw_SW_tree
; 	update_tree_addr #40, TREE_LSB, TREE_MSB, TREE_CLR_LSB, TREE_CLR_MSB, addOffset
;   beq .draw_S_tree
; 	erase_char #PATH, TREE_CLR, TREE_CLR_LSB, TREE_LSB
; .draw_S_tree
; 	update_tree_addr #2, TREE_LSB, TREE_MSB, TREE_CLR_LSB, TREE_CLR_MSB, addOffset
;   beq .draw_SE_tree
; 	erase_char #PATH, TREE_CLR, TREE_CLR_LSB, TREE_LSB
; .draw_SE_tree
; 	update_tree_addr #2, TREE_LSB, TREE_MSB, TREE_CLR_LSB, TREE_CLR_MSB, addOffset
;   beq .done_trees
; 	erase_char #PATH, TREE_CLR, TREE_CLR_LSB, TREE_LSB
; .done_trees
; 	rts

; draw_env: subroutine
; .draw_NW_tree
; 	update_tree_addr #46, SPRITE_LSB, SPRITE_MSB, SPRITE_CLR_LSB, SPRITE_CLR_MSB, subOffset
;   beq .draw_N_tree
; 	draw_char TREE_SPRITE, TREE_CLR, TREE_CLR_LSB, TREE_LSB
; .draw_N_tree
; 	update_tree_addr #2, TREE_LSB, TREE_MSB, TREE_CLR_LSB, TREE_CLR_MSB, addOffset
; 	beq .draw_NE_tree
; 	draw_char TREE_SPRITE, TREE_CLR, TREE_CLR_LSB, TREE_LSB
; .draw_NE_tree
; 	update_tree_addr #2, TREE_LSB, TREE_MSB, TREE_CLR_LSB, TREE_CLR_MSB, addOffset
;   beq .draw_W_tree
; 	draw_char TREE_SPRITE, TREE_CLR, TREE_CLR_LSB, TREE_LSB
; .draw_W_tree
; 	update_tree_addr #40, TREE_LSB, TREE_MSB, TREE_CLR_LSB, TREE_CLR_MSB, addOffset
;   beq .draw_E_tree
; 	draw_char TREE_SPRITE, TREE_CLR, TREE_CLR_LSB, TREE_LSB
; .draw_E_tree
; 	update_tree_addr #4, TREE_LSB, TREE_MSB, TREE_CLR_LSB, TREE_CLR_MSB, addOffset
;   beq .draw_SW_tree
; 	draw_char TREE_SPRITE, TREE_CLR, TREE_CLR_LSB, TREE_LSB
; .draw_SW_tree
; 	update_tree_addr #40, TREE_LSB, TREE_MSB, TREE_CLR_LSB, TREE_CLR_MSB, addOffset
;   beq .draw_S_tree
; 	draw_char TREE_SPRITE, TREE_CLR, TREE_CLR_LSB, TREE_LSB
; .draw_S_tree
; 	update_tree_addr #2, TREE_LSB, TREE_MSB, TREE_CLR_LSB, TREE_CLR_MSB, addOffset
;   beq .draw_SE_tree
; 	draw_char TREE_SPRITE, TREE_CLR, TREE_CLR_LSB, TREE_LSB
; .draw_SE_tree
; 	update_tree_addr #2, TREE_LSB, TREE_MSB, TREE_CLR_LSB, TREE_CLR_MSB, addOffset
;   beq .done_trees
; 	draw_char TREE_SPRITE, TREE_CLR, TREE_CLR_LSB, TREE_LSB
; .done_trees
; 	rts

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
