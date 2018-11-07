; MACROS

; loads coordinate into [{1}] and adds [{2}]
; result stored in accumulator
  mac inc_maze_coord
  lda [{1}]
  clc
  adc [{2}]
  endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;
; loads coordinate into [{1}] and subtracts [{2}]
; result stored in accumulator
  mac dec_maze_coord
  lda [{1}]
  sec
  sbc [{2}]
  endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;
; loads offset increment into accumulator
; updates addresses OFFSET, MAZE_LSB, MAZE_MSB
; executes add/subOffset in [{2}]
; result stored in accumulator
  mac load_maze_offsets
  lda [{1}]
  sta OFFSET
  lda MAZE_LSB
  ldx MAZE_MSB
  jsr [{2}]
  endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;
; stores maze offsets into corresponding
; addresses after offsets are updated
; follows 'load_maze_offsets' macro
  mac store_maze_offsets
  sta MAZE_MSB
  lda LSB
  sta MAZE_LSB
  endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;
; needs sprite clr in [{1}],
; sprite_clr_lsb in [{2}],
; and sprite_lsb in [{3}]
  mac draw_sprite
  lda [{1}]
  sta ([{2}]),y
  txa
  sta ([{3}]),y
  endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;
; needs sprite to draw in [{1}],
; sprite_clr in [{2}],
; sprite_clr_lsb in [{3}]
; sprite_lsb in [{4}]
  mac draw_char
	ldx	[{1}]
	ldy	#$00    ; draw 1st char
	draw_sprite [{2}], [{3}], [{4}]
	inx       	; draw 2nd char
	ldy	#$16
	draw_sprite [{2}], [{3}], [{4}]
	inx 	    	; draw 3rd char
	ldy	#$01
	draw_sprite [{2}], [{3}], [{4}]
	inx   	   	; draw 4th char
	ldy #$17
	draw_sprite [{2}], [{3}], [{4}]
  endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;