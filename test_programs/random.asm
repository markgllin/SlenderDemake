LFSR = $2
CHROUT = $ffd2
FRAME = $fb

	processor 6502
  org $1001
  DC.W end
  DC.W 1234
  DC.B $9e, " 4110", 0
end
  dc.w 0

  jsr clr

  ldx #12								; ugly background
	stx 36879

  lda #39
  sta LFSR

  ldx #0
loop
  jsr startFrame
  jsr random
  sta 7680,x
  inx
  cpx #255
  bne loop
done
  jmp done

; 00100111
;   001001 11
; ------------
; 00101110  
;  0010011 1
;     0010 0111
random
  lda LFSR
  ldy LFSR
  lsr LFSR                    ; 00010011 1  = 19
  lsr LFSR                    ; 00001001 1  = 9
  eor LFSR    ; 6th tap   ; 00101110 1  = 46
  lsr LFSR                    ; 00010111 1
  eor LFSR    ; 5th tap   ; 00110000 1
  lsr LFSR                    ; 00011000 0
  eor LFSR    ; 4th tap   ; 00111111 0
  and #1                  ; 00000001 0
  sty LFSR
  lsr LFSR
  clc
  ror
  ror                      ; 10000000 1
  ora LFSR                 ; 10010011 1
  sta LFSR
  rts

clr
  lda #147            ; screen clear (pg 42)
  jsr CHROUT
  rts

startFrame	
  lda	#$00
	sta	FRAME	
frame	
  lda	$9004		; raster beam line number
	cmp	#$0		; top of the screen
	bne frame
	inc	FRAME		; increase frame counter
	lda	FRAME
	cmp	#$99		; add delay
	bne	frame
  rts