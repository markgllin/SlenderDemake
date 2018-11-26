; COMMON SUBROUTINES

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

; ;clears screen
; clr             subroutine
;         lda     #CLEAR_CHAR
;         ldx     #0
; .clrloop:
;         sta     $1e00,x
;         sta     $1f00,x
;         inx
;         bne     .clrloop
;         rts

; startFrame      subroutine
;         ldx     #$00
;         stx     FRAME
; .frame:
;         lda     RASTER          ; raster beam line number
;         bne     .frame
;         inx                ; increase frame counter
;         cpx     #$19            ; add delay
;         bne     .frame
;         rts

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;              SPLASHSCREENS               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; expects message address in MSG_ADDR_LSB/MSB
; expects message offset in SCRN_OFFSET_LSB/MSB
print_message:
	ldy	#0
print_message_loop:
	lda	(MSG_ADDR_LSB),y		; grab index for characters
	cmp	#END_BYTE
	beq	done_printing

	sta	(SCRN_OFFSET_LSB),y		; print message starting at $1f35 on screen
	iny

	jmp	print_message_loop

done_printing:
	rts

;; preps for a splash screen by setting the correct colours, clearing
;; the entire screen, and copying the necessary characters
prep_splash_screen:
        lda     #20
        ldx     #0
start_clr_loop:
        sta     $1e00,x
        sta     $1f00,x
        inx
        bne     start_clr_loop

	lda     #8              ; border black, screen black (ref p. 265)
        sta     SCR_C

	ldx	#00		
	lda	#01
fill_colour_mem:		; fill colour memory with white
	sta	COLOR_MEM,X
	sta	COLOR_MEM+#$ff,X
	inx
	bne	fill_colour_mem

        rts


