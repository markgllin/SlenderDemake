;;; ----- MOVEMENT ROUTINES
check_movement:
        ;; collision checks
        ldy     #$00            ; top left corner
        lda     (SPRITE_LSB),y
        cmp     #PATH
        bne     collision
        ldy     #$01            ; top right corner
        lda     (SPRITE_LSB),y
        cmp     #PATH
        bne     collision
        ldy     #$16            ; bottom left corner
        lda     (SPRITE_LSB),y
        cmp     #PATH
        bne     collision
        ldy     #$17            ; bottom right corner
        lda     (SPRITE_LSB),y
        cmp     #PATH
        bne     collision

        ;; no collisions
        rts
collision:
        cmp     #ITEM_LETTER
        beq     letter_found
        cmp     #ITEM_LETTER + 1
        bne     invalid_movement
letter_found:
        ;; found a letter!
        ;; so update the score
        ldy     #$01            ; second digit from the left
        lda     (SCORE_LSB),y
        cmp     #NUM_NINE
        bne     score_no_wrap

        ;; score wraps, so do that
	;; we only check for a SINGLE WRAP --- i.e. the maximum score is 9900
	;; anything more than that and our code will break, but this was on purpose
	;; what are the chances that someone can find 99 letters in the allocated time?
        lda     #NUM_ZERO
        sta     (SCORE_LSB),y

        dey
        lda     (SCORE_LSB),y
        clc
        adc     #$01
        sta     (SCORE_LSB),y
        jmp     done_score

score_no_wrap:
        clc
        adc     #$01
        sta     (SCORE_LSB),y

done_score:
        ;; and erase the letter
        lda     #PATH
        ldy     #$00
        sta     (LETTER_LSB),y
        iny
        sta     (LETTER_LSB),y

        rts

invalid_movement:
        ;; restore previous position
        lda     PREV_SPRITE_LSB
        sta     SPRITE_LSB
	sta     SPRITE_CLR_LSB
        lda     PREV_SPRITE_MSB
        sta     SPRITE_MSB
        lda     PREV_SPRITE_CLR_MSB
        sta     SPRITE_CLR_MSB

        lda     SPRITE_PREV_X
        sta     SPRITE_X
        lda     SPRITE_PREV_Y
        sta     SPRITE_Y
        rts

save_previous:
        lda     SPRITE_LSB
        sta     PREV_SPRITE_LSB
	sta     PREV_SPRITE_CLR_LSB
        lda     SPRITE_MSB
        sta     PREV_SPRITE_MSB
        lda     SPRITE_CLR_MSB
        sta     PREV_SPRITE_CLR_MSB

        lda     SPRITE_X
        sta     SPRITE_PREV_X
        lda     SPRITE_Y
        sta     SPRITE_PREV_Y

        rts

; needs move increment in Y register
addSpriteOffset:
        jsr     save_previous
        tya                     ;2      ; move increment in acumulator
        clc                     ;2      ; clear the carry
        adc     SPRITE_LSB      ;3      ; add to LSB
        sta     SPRITE_LSB      ;3      ; store result in LSB
	sta	SPRITE_CLR_LSB		; ALWAYS the same 

        bcc     addOffset_no_carry;~2

        inc     SPRITE_MSB      ;5
        inc     SPRITE_CLR_MSB  ;5

addOffset_no_carry:
        rts

subSpriteOffset:
        jsr     save_previous
        Lda     SPRITE_LSB      ;3
        sty     SPRITE_LSB      ;3
        sec                     ;2     ; clear the borrow
        sbc     SPRITE_LSB      ;3     ; sub from LSB
        sta     SPRITE_LSB      ;3     ; store result in LSB
        sta     SPRITE_CLR_LSB  ;3

        bcs     subOffset_no_borrow;~2

        dec     SPRITE_MSB      ;3
        dec     SPRITE_CLR_MSB  ;3

subOffset_no_borrow:
        rts
