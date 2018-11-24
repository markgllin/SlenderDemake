; COMMON SUBROUTINES

;clears screen
clr             subroutine
        lda     #CLEAR_CHAR
        ldx     #0
.clrloop:
        sta     $1e00,x
        sta     $1f00,x
        inx
        bne     .clrloop
        rts

; random value returned in accumulator
; and stored in LFSR (mem address)
; alters Y register and accumulator
random          subroutine
        lda     LFSR
        ldy     LFSR
        lsr     LFSR
        lsr     LFSR
        eor     LFSR            ; 6th tap
        lsr     LFSR
        eor     LFSR            ; 5th tap
        lsr     LFSR
        eor     LFSR            ; 4th tap
        and     #1
        sty     LFSR
        lsr     LFSR
        clc
        ror
        ror
        ora     LFSR
        sta     LFSR
        rts

; needs LSB in accumulator and MSB in X
; needs offset in OFFSET
; returns values in OFFSET, LSB, AND MSB
; also returns MSB accumulator
addOffset       subroutine
        clc                     ; clear the carry
        adc     OFFSET          ; add to LSB
        sta     LSB             ; store result in LSB
        TXA
        adc     #0              ; add carry to MSB
        sta     MSB             ; store MSB
        rts

; needs LSB in accumulator and MSB in X
; needs offset in OFFSET
; returns values in OFFSET, LSB, AND MSB
; also returns MSB accumulator
subOffset       subroutine
        sec
        sbc     OFFSET
        sta     LSB
        TXA
        sbc     #0
        sta     MSB
        rts


startFrame      subroutine
        lda     #$00
        sta     FRAME
.frame:
        lda     RASTER          ; raster beam line number
        bne     .frame
        inc     FRAME           ; increase frame counter
        lda     FRAME
        cmp     #$15            ; add delay
        bne     .frame
        rts

; displays player coordinates in bottom left corner
; debugCoordinates
;        lda     SPRITE_X
;        CLC
;        adc     #NUM_ZERO
;        sta     8164
;        lda     SPRITE_Y
;        CLC
;        adc     #NUM_ZERO
;        sta     8165
;        rts
