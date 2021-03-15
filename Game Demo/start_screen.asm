start_screen:
        jsr     prep_splash_screen
        lda     #$80
        sta     PRINT_MODE

        ;; store screen address MSB for plotting
        lda     #$1e
        sta     SP_SCREEN_MSB
        lda     #0
        sta     CHAR_NUM_CTR                    ; counter for character num
        sta     MAZE_SEED                       ; counter for seeding maze generation

        ldy     #0                              ; counter for columns
print_logo_row:
        ldx     #0                              ; counter for rows
        lda     #$5e                            ; offset of logo
        sta     SP_SCREEN_LSB                   ; LSB of screen memory - prints at offset
print_logo_column:
        lda     CHAR_NUM_CTR                    ; print the current character
        sta     ($00),y
        inc     CHAR_NUM_CTR                    ; get the next character
        lda     $00                             ; jump down one row
        clc
        adc     #$16
        sta     SP_SCREEN_LSB
        inx                                     ; check if 5 rows have been printed
        cpx     #5
        bne     print_logo_column

        iny                                     ; check if 9 columns have been printed
        cpy     #9
        bne     print_logo_row

        lda     #<message                       ; get low byte of message address to print
        sta     MSG_ADDR_LSB
        lda     #>message                       ; get high byte of message address to print
        sta     MSG_ADDR_MSB

        jsr     print_message                   ; common subroutines

        lda     #SEED                           ; init the SEEEED for RNG glitching
        sta     LFSR
start_input:
        inc     MAZE_SEED
        jsr     random
        cmp     #20
        bne     no_glitch

        jsr     glitch

no_glitch:
        lda     SCAN_KEYBOARD
        cmp     #SPACE_KEY
        bne     start_input

        lda     MAZE_SEED
        sta     LFSR
        rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;              SUBROUTINES               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; create a glitch effect
glitch:
        lda     #GLITCH_COUNT
        sta     GLITCH_CTR
glitch_loop:
        inc     SCRN_V
        inc     SCRN_H
        dec     GLITCH_CTR
        bne     glitch_loop

        lda     #GLITCH_COUNT
        sta     GLITCH_CTR
glitch_undo:
        dec     SCRN_V
        dec     SCRN_H
        dec     GLITCH_CTR
        bne     glitch_undo

        rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                 DATA                   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

message:                                        ; "PRESS SPACE TO START"  -> 22 bytes
        dc.b    #$1f, #$35-2                    ; position on screen (minus 2)
        ;   	P   R   E  S   S
        dc.b    16, 18, 5, 19, 19, 32
        ;	S   P   A  C  E
        dc.b    19, 16, 1, 3, 5, 32
        ;   	T   O       S   T   A  R   T (with high bit set)
        dc.b    20, 15, 32, 19, 20, 1, 18, 20+$80
