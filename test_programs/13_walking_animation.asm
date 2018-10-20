; pg179 for character keys
; pg270 screen memory maps
;
; this took me longer than i'm willing to admit.
; and only in 1 direction too.....
; 
; needs some major refactoring which i'll do later on
CHROUT = $ffd2
FRAME = $fb

	processor 6502
  org $1001
  DC.W end
  DC.W 1234
  DC.B $9e, " 4110", 0
end
  dc.w 0

  ldx #12								; ugly background
	stx 36879
  jsr clr

  ; loading our sprite into memory
  ldx #0
  jsr loadChar

  lda #$ff
  sta $9005     ; start of character memory (pg 175)

  lda #$00              ; load LSB
  sta $0

  lda #$1e              ; load MSB
  sta $1

  lda #4
  sta $2                ; set sprite direction/movement

input
  jsr startFrame
  lda $00c5   ; current key pressed (pg 172)
  cmp #64
  beq nothing
  cmp #41     ;s
  beq down
  jmp input
nothing
  jsr erase
  lda #4
  sta $2
  ldx #0
  jmp doneInput
down
  jsr erase
  ldy #22
  jsr addOffset
  lda $2
  eor #1
  sta $2
  ldx #0
  jmp doneInput
doneInput
  jmp drawDir

; needs move increment in Y register
addOffset
  TYA             ;2      ; move increment in acumulator
  clc             ;2      ; clear the carry
  adc $0          ;3      ; add to LSB
  sta $0          ;3      ; store result in LSB
  lda #0          ;2
  adc $1          ;3      ; add carry to MSB
  sta $1          ;3      ; store MSB
  rts      ;total: 18 cycles

subOffset
  lda $0           ;3
  sty $0           ;3
  clc              ;2     ; clear the carry
  sbc $0           ;3     ; sub from LSB
  sta $0           ;3     ; store result in LSB

  lda $1           ;3
  sbc #0           ;2     ; add carry to MSB
  sta $1           ;3     ; store MSB
  rts      ;total: 22 cycles --> WHY DOES IT ANIMATE FASTER WHEN IT HAS MORE CYCLES

erase
  ldx #32     ; load blank
  ldy #0
  jsr draw
  ldy #1
  jsr draw
  ldy #22
  jsr draw
  ldy #23
  jsr draw
  rts

drawDir  
  lda $2
  cmp #4
  beq drawStill
  and #1
  beq drawLeft
  and #0
  beq drawRight
  rts

drawStill
  ldx #0
  jsr drawChar
  jmp input
drawLeft
  ldx #16
  jsr drawChar
  lda #2
  sta $2
  jmp input
drawRight
  ldx #20
  jsr drawChar
  lda #1
  sta $2
  jmp input

drawChar
  ldy #0      ; draw 1st char
  jsr draw
  inx      ; draw 2nd char
  ldy #22
  jsr draw
  inx      ; draw 3rd char
  ldy #1
  jsr draw
  inx      ; draw 4th char
  ldy #23
  jsr draw
  rts

; needs character to draw in x
; needs offset in y
draw
  txa
  sta ($0),y
  rts

;----------------------

startFrame	
  lda	#$00
	sta	FRAME	
frame	
  lda	$9004		; raster beam line number
	cmp	#$0		; top of the screen
	bne frame
	inc	FRAME		; increase frame counter
	lda	FRAME
	cmp	#$40		; add delay
	bne	frame
  rts

clr
  lda #147            ; screen clear (pg 42)
  jsr CHROUT
  rts

loadChar
  lda characterSprite,x
  sta $1c00,x
  inx
  cpx #192
  bne loadChar
  rts

; Pokemon scientist sprite I shamelessly copied 
; because I have no creativity nor imagination.
; can probably make lots of optimizations in this
; instead of copy/pasting duplicate char
characterSprite
  ; standing still facing down
  dc.b 3, 15, 10, 24, 48, 86, 73, 73
  dc.b 54, 56, 75, 73, 48, 16, 31, 14
  dc.b 192, 248, 120, 24, 12, 106, 146, 146
  dc.b 108, 28, 210, 146, 12, 8, 248, 112

  ;standing still facing up 
  dc.b 3,15,31,31,63,95,95,95
  dc.b 55,56,91,80,48,17,31,14
  dc.b 192,240,248,248,252,250,250,250
  dc.b 236,28,218,10,12,136,248,112

  ;standing still facing left
  dc.b 7,15,31,19,17,24,23,20
  dc.b 24,8,7,5,5,4,7,3
  dc.b 224,240,248,248,252,252,252,152
  dc.b 16,96,208,48,48,208,240,192

  ;standing still facing right
  dc.b 7,15,31,31,63,63,63,25
  dc.b 8,6,11,12,12,11,15,3
  dc.b 224,240,248,200,136,24,232,40
  dc.b 24,16,224,160,160,32,224,192

  ;walking left foot
  dc.b 3, 15, 10, 24, 48, 86, 73, 73
  dc.b 73, 118, 88, 63, 27, 12, 15, 7
  dc.b 192, 248, 120, 24, 12, 106, 146, 146
  dc.b 146, 108, 28, 244, 204, 72, 176, 0

  ;walking right foot
  dc.b 3, 15, 10, 24, 48, 86, 73, 73
  dc.b 73,54,56,47,51,18,13,0
  dc.b 192, 248, 120, 24, 12, 106, 146, 146
  dc.b 146,110,26,252,216,48,240,224

; walk right foot right side
; 01001001  73
; 01110110  118
; 01011000  88
; 00111111  63
; 00011011  27
; 00001100  12
; 00001111  15
; 00000111  7


; walk right foot left side
; 10010010 146
; 01101100 108
; 00011100 28
; 11110100 244
; 11001100 204
; 01001000 72
; 10110000 176
; 00000000 0

;Stationary
;left top
; 00000011  3
; 00001111  15
; 00011110  10
; 00011000  24
; 00110000  48
; 01010110  86
; 01001001  73
; 01001001  73

;left bottom
; 00110110  54
; 00111000  56
; 01001011  75
; 01001001  73
; 00110000  48
; 00010000  16
; 00011111  31
; 00001110  14

;right top
; 11000000  192
; 11111000  248
; 01111000  120
; 00011000  24
; 00001100  12
; 01101010  106
; 10010010  146
; 10010010  146

;right bottom
; 01101100  108
; 00011100  28
; 11010010  210
; 10010010  146
; 00001100  12
; 00001000  8
; 11111000  248
; 01110000  112


; facing up
; 00000011 11000000
; 00001111 11110000
; 00011111 11111000
; 00011111 11111000
; 00111111 11111100
; 01011111 11111010
; 01011111 11111010
; 01011111 11111010

; 00110111 11101100
; 00111000 00011100
; 01011011 11011010
; 01010000 00001010
; 00110000 00001100
; 00010001 10001000
; 00011111 11111000
; 00001110 01110000

; facing left
; 00000111
; 00001111
; 00011111
; 00010011
; 00010001
; 00011000
; 00010111
; 00010100
; 00011000
; 00001000
; 00000111
; 00000101
; 00000101
; 00000100
; 00000111
; 00000011
; 11100000
; 11110000
; 11111000
; 11111000
; 11111100
; 11111100
; 11111100
; 10011000
; 00010000
; 01100000
; 11010000
; 00110000
; 00110000
; 11010000
; 11110000
; 11001111