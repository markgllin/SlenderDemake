; MACROS

; loads coordinate into [{1}] and adds [{2}]
; result stored in accumulator
        mac     inc_maze_coord
            lda     [{1}]
            clc
            adc     [{2}]
        endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;
; loads coordinate into [{1}] and subtracts [{2}]
; result stored in accumulator
        mac     dec_maze_coord
            lda     [{1}]
            sec
            sbc     [{2}]
        endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;
; loads offset increment into accumulator
; updates addresses OFFSET, MAZE_LSB, MAZE_MSB
; executes add/subOffset in [{2}]
; result stored in accumulator
        mac     load_maze_offsets
            lda     [{1}]
            sta     OFFSET
            lda     MAZE_LSB
            ldx     MAZE_MSB
            jsr     [{2}]
        endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;
; stores maze offsets into corresponding
; addresses after offsets are updated
; follows 'load_maze_offsets' macro
        mac     store_maze_offsets
            sta     MAZE_MSB
            lda     LSB
            sta     MAZE_LSB
        endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;
; needs sprite clr in [{1}],
; sprite_clr_lsb in [{2}],
; and sprite_lsb in [{3}]
; and sprite character in X
        mac     draw_sprite
            lda     [{1}]
            sta     ([{2}]),y		; fill colour memory
            txa
            sta     ([{3}]),y		; fill screen memory
        endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;
; needs sprite to draw in [{1}],
; sprite_clr in [{2}],
; sprite_clr_lsb in [{3}]
; sprite_lsb in [{4}]
        mac     draw_char
            ldx     [{1}]
            ldy     #$00            ; draw 1st char
            draw_sprite [{2}], [{3}], [{4}]
            inx                     ; draw 2nd char
            ldy     #$16
            draw_sprite [{2}], [{3}], [{4}]
            inx                     ; draw 3rd char
            ldy     #$01
            draw_sprite [{2}], [{3}], [{4}]
            inx                     ; draw 4th char
            ldy     #$17
            draw_sprite [{2}], [{3}], [{4}]
        endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;
; needs sprite to erase in [{1}],
; sprite_clr in [{2}],
; sprite_clr_lsb in [{3}]
; sprite_lsb in [{4}]
        mac     erase_char
            ldx     [{1}]
            ldy     #$00            ; draw 1st char
            draw_sprite [{2}], [{3}], [{4}]
            ldy     #$16
            draw_sprite [{2}], [{3}], [{4}]
            ldy     #$01
            draw_sprite [{2}], [{3}], [{4}]
            ldy     #$17
            draw_sprite [{2}], [{3}], [{4}]
        endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;
; needs offset in [{1}]
; needs sprite lsb in [{2}]
; needs sprite msb in [{3}]
; needs sprite clr lsb in [{4}]
; needs sprite clr msb in [{5}]
; needs add/subOffset subroutine in [{6}]
        mac     update_tree_addr
            lda     [{1}]
            sta     OFFSET
            lda     [{2}]
            ldx     [{3}]
            jsr     [{6}]
            sta     TREE_MSB
            lda     LSB
            sta     TREE_LSB

            lda     [{4}]
            ldx     [{5}]
            jsr     [{6}]
            sta     TREE_CLR_MSB
            lda     LSB
            sta     TREE_CLR_LSB

            ldy     #$00
            lda     (TREE_LSB),y
            cmp     #PATH
        endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;
; needs digit number in [{1}]
; needs branch in [{2}]
	mac	check_wrap
            ldy     #[{1}]           ; check digit #[{1}]
            lda     (SCRN_LSB),y
            cmp     #NUM_ZERO
            beq     [{2}]

            sec
            sbc     #$01
            sta     (SCRN_LSB),y
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;
	    
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;
; needs voice index in [{1}]
; needs voice notes in [{2}]
	mac	next_note
	    ldx     [{1}]
            inx			; incrementing 3 times actually takes less bytes
            inx			; than adding 3 using the accumulator and transfering
            inx
            lda     [{2}],X 
	    stx     [{1}]
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;


