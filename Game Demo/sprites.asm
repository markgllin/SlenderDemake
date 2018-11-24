;; sprite animation

animate_sprite:
        dec     ANIMATE_COUNT
        bne     done_animate

        lda     ANIMATE_STATUS
        bne     animate_blink
animate_open:
        lda     #$ff
        sta     ANIMATE_STATUS

        lda     CURR_SPRITE
        clc
        adc     #$10
        sta     CURR_SPRITE

        jmp     draw_animate
animate_blink:
        lda     #$00
        sta     ANIMATE_STATUS

        lda     CURR_SPRITE
        sec
        sbc     #$10
        sta     CURR_SPRITE
draw_animate:
        draw_char CURR_SPRITE, CURR_CLR, SPRITE_CLR_LSB, SPRITE_LSB
        lda     #ANIMATION_DELAY
        sta     ANIMATE_COUNT
done_animate:
        rts

;;; ----- DRAWING ROUTINES

place_letter: ; ************** CHANGE THIS ****************
        lda     LFSR
        jsr     random

        sta     LETTER_LSB
        sta     LETTER_CLR_LSB

        ldy     #$0
        lda     (LETTER_LSB),y
        cmp     #PATH
        bne     place_letter

        ldy     #$1
        lda     (LETTER_LSB),y
        cmp     #PATH
        bne     place_letter

        ldy     #$0
        lda     #ITEM_LETTER
        sta     (LETTER_LSB),y
        lda     #$01
        sta     (LETTER_CLR_LSB),y

        iny
        lda     #ITEM_LETTER + 1
        sta     (LETTER_LSB),y
        lda     #$01
        sta     (LETTER_CLR_LSB),y

        rts

erase:
        erase_char #PATH, CURR_CLR, SPRITE_CLR_LSB, SPRITE_LSB
        rts

draw_env:       subroutine
.draw_NW_tree
        update_tree_addr #46, SPRITE_LSB, SPRITE_MSB, SPRITE_CLR_LSB, SPRITE_CLR_MSB, subOffset; use player location and offset by -46 to draw (top left) tree
        beq     .draw_N_tree    ; if it's a path, don't draw
        jsr     applyMask
.draw_N_tree
        update_tree_addr #2, TREE_LSB, TREE_MSB, TREE_CLR_LSB, TREE_CLR_MSB, addOffset
        beq     .draw_NE_tree
        jsr     applyMask
.draw_NE_tree
        update_tree_addr #2, TREE_LSB, TREE_MSB, TREE_CLR_LSB, TREE_CLR_MSB, addOffset
        beq     .draw_W_tree
        jsr     applyMask
.draw_W_tree
        update_tree_addr #40, TREE_LSB, TREE_MSB, TREE_CLR_LSB, TREE_CLR_MSB, addOffset
        beq     .draw_E_tree
        jsr     applyMask
.draw_E_tree
        update_tree_addr #4, TREE_LSB, TREE_MSB, TREE_CLR_LSB, TREE_CLR_MSB, addOffset
        beq     .draw_SW_tree
        jsr     applyMask
.draw_SW_tree
        update_tree_addr #40, TREE_LSB, TREE_MSB, TREE_CLR_LSB, TREE_CLR_MSB, addOffset
        beq     .draw_S_tree
        jsr     applyMask
.draw_S_tree
        update_tree_addr #2, TREE_LSB, TREE_MSB, TREE_CLR_LSB, TREE_CLR_MSB, addOffset
        beq     .draw_SE_tree
        jsr     applyMask
.draw_SE_tree
        update_tree_addr #2, TREE_LSB, TREE_MSB, TREE_CLR_LSB, TREE_CLR_MSB, addOffset
        beq     .done_trees
        jsr     applyMask
.done_trees
        rts

applyMask       subroutine
        lda     SPRITE_Y        ; boundary check for entrance and exit of maze
        cmp     #9
        beq     .checkSpriteX   ; (3,9) and (20,9) are the boundaries for drawing trees
.drawAllSegments                ; otherwise, trees will wrap around screen
        ldx     TREE1
        ldy     #$00
        jsr     treeSegments
        ldy     #$16
        jsr     treeSegments
        ldy     #$01
        jsr     treeSegments
        ldy     #$17
        jsr     treeSegments
        rts
.checkSpriteX
        lda     SPRITE_X
        cmp     #3
        bmi     .doneDrawing
        cmp     #20
        bcs     .doneDrawing
        jmp     .drawAllSegments
.doneDrawing
        rts

treeSegments    subroutine
        lda     (TREE_LSB),y
        cmp     #CLEAR_CHAR_TL
        beq     .drawTL
        cmp     #CLEAR_CHAR_TR
        beq     .drawTR
        cmp     #CLEAR_CHAR_BL
        beq     .drawBL
        cmp     #CLEAR_CHAR_BR
        beq     .drawBR
        rts
.drawTL
        ldx     #(CLEAR_CHAR_TL+OFFSET_TO_TREES)
        draw_sprite #TREE_CHAR_COLOR, TREE_CLR_LSB, TREE_LSB
        rts
.drawTR
        ldx     #(CLEAR_CHAR_TR+OFFSET_TO_TREES)
        draw_sprite #TREE_CHAR_COLOR, TREE_CLR_LSB, TREE_LSB
        rts
.drawBL
        ldx     #(CLEAR_CHAR_BL+OFFSET_TO_TREES)
        draw_sprite #TREE_CHAR_COLOR, TREE_CLR_LSB, TREE_LSB
        rts
.drawBR
        ldx     #(CLEAR_CHAR_BR+OFFSET_TO_TREES)
        draw_sprite #TREE_CHAR_COLOR, TREE_CLR_LSB, TREE_LSB
        rts

;;; ---- SPRITES AND STUFF
sprite:
        ;;  sprite facing forward
        BYTE    21,85,118,89,89,30,90,85
        BYTE    7,31,31,31,127,85,4,4
        BYTE    84,84,164,152,152,172,164,85
        BYTE    208,100,100,220,253,85,16,16

        ;; sprite facing backward
        BYTE    21,85,117,85,85,85,85,21
        BYTE    7,31,31,127,127,85,4,4
        BYTE    84,85,85,85,85,85,85,84
        BYTE    208,244,244,253,253,85,16,16

        ;; sprite facing to the right
        BYTE    21,85,117,94,86,87,22,85
        BYTE    7,31,31,31,127,85,16,16
        BYTE    84,84,164,100,105,164,164,80
        BYTE    208,244,217,217,244,84,16,16

        ;; sprite facing to the left
        BYTE    21,21,26,25,105,26,26,5
        BYTE    7,31,103,103,31,21,4,4
        BYTE    84,85,85,149,149,213,148,85
        BYTE    208,244,244,244,253,85,4,4

        ;; sprite facing forward -- blinking
        BYTE    0,21,85,118,90,89,30,90
        BYTE    85,7,31,31,31,127,85,4
        BYTE    0,84,84,164,168,152,172,164
        BYTE    85,208,100,100,220,253,85,16

        ;; sprite facing backward -- blinking
        BYTE    0,21,85,117,85,85,85,85
        BYTE    21,7,31,31,127,127,85,4
        BYTE    0,84,85,85,85,85,85,85
        BYTE    84,208,244,244,253,253,85,16

        ;; sprite facing to the left -- blinking
        BYTE    0,21,85,117,94,86,87,22
        BYTE    21,7,31,31,31,127,85,16
        BYTE    0,84,84,164,164,105,164,164
        BYTE    80,208,244,217,217,244,84,16

        ;; sprite facing to the right -- blinking
        BYTE    0,21,21,26,26,105,26,26
        BYTE    5,7,31,103,103,31,21,4
        BYTE    0,84,85,85,149,149,213,148
        BYTE    85,208,244,244,244,253,85,4
tree1:
        BYTE    1,1,7,1,7,30,7,30
        BYTE    26,122,30,122,85,1,1,5
        BYTE    64,64,144,64,144,164,144,164
        BYTE    164,169,164,169,85,64,64,80

letter:
        BYTE    0,15,11,13,14,15,15,0
        BYTE    0,240,208,176,112,240,240,0

