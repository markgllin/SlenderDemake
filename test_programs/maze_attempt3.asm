NORTH = 0   ;@
SOUTH = 1   ;A
EAST = 2    ;B
WEST = 3    ;C

CLEAR_CHAR = 32

LFT_SCRN_BNDRY = 0
RGHT_SCRN_BNDRY = 21
TOP_SCRN_BNDRY = 0
BTM_SCRN_BNDRY = 21

X_OFFSET = 1
Y_OFFSET = 22

SCRN_LSB = $00
SCRN_MSB = $1e

MAZE_LSB = $00
MAZE_MSB = $1e

LFSR = $3
MAZE_X_COORD = $10
MAZE_Y_COORD = $11
DIR = $4
FRAME = $fb

	processor 6502

;;;;;;;;;;;;;;;;;;;;;;;;;;;
  mac chk_scrn_bndry
  cmp [{1}]
  endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

  org $1001
  DC.W end
  DC.W 1234
  DC.B $9e, " 4110", 0
end
  dc.w 0

  ldx #12								; ugly background
	stx 36879

  jsr clr

  lda #2
  sta MAZE_X_COORD                ; x-coord
  lda #2
  sta MAZE_Y_COORD                ; y-coord

  sta $1e2e

  lda #$2e ;#MAZE_LSB              ; load LSB
  sta $0

  lda #$1e ;#MAZE_MSB              ; load MSB
  sta $1

  lda #94       ; special symbol for maze origin
  sta $1e2e

  lda #240
  sta LFSR
generateMaze
  jsr startFrame

  jsr rndDirection
  sta DIR

  jsr isCellValid
  bcs validCell
invalidCell
  lda #NORTH
  jsr isCellValid
  bcs generateMaze

  lda #SOUTH
  jsr isCellValid
  bcs generateMaze

  lda #EAST
  jsr isCellValid
  bcs generateMaze

  lda #WEST
  jsr isCellValid
  bcs generateMaze
backtrack
  ldy #0              
  lda ($0),y          ; load value of current cell into accumulator

  cmp #94
  beq done

  TAX

  jsr drawPath

  TXA
  cmp #NORTH
  beq goSouth
  cmp #SOUTH
  beq goNorth
  cmp #EAST
  beq goWest
goEast
  inc_maze_coord MAZE_X_COORD, #4
  sta MAZE_X_COORD

  lda #(X_OFFSET * 4)
  jsr addOffset
  jmp generateMaze
goSouth
  inc_maze_coord MAZE_Y_COORD, #4
  sta MAZE_Y_COORD

  lda #(Y_OFFSET * 4)
  jsr addOffset
  jmp generateMaze
goNorth
  dec_maze_coord MAZE_Y_COORD, #4
  sta MAZE_Y_COORD

  lda #(Y_OFFSET * 4)
  jsr subOffset
  jmp generateMaze
goWest
  dec_maze_coord MAZE_X_COORD, #4
  sta MAZE_X_COORD

  lda #(X_OFFSET * 4)
  jsr subOffset
  jmp generateMaze

done
  jsr drawPath
  jmp loop

loop
  jmp loop

validCell
  lda DIR
  cmp #NORTH
  beq updateNorthCell
  cmp #SOUTH
  beq updateSouthCell
  cmp #EAST
  beq updateEastCell
updateWestCell
  dec_maze_coord MAZE_X_COORD, #4
  sta MAZE_X_COORD

  lda #(X_OFFSET * 4)
  jsr subOffset

  lda #WEST
  jsr draw
  jmp generateMaze
updateNorthCell
  dec_maze_coord MAZE_Y_COORD, #4
  sta MAZE_Y_COORD

  lda #(Y_OFFSET * 4)
  jsr subOffset
  
  lda #NORTH
  jsr draw
  jmp generateMaze
updateSouthCell
  inc_maze_coord MAZE_Y_COORD, #4
  sta MAZE_Y_COORD

  lda #(Y_OFFSET * 4)
  jsr addOffset

  lda #SOUTH
  jsr draw
  jmp generateMaze
updateEastCell
  inc_maze_coord MAZE_X_COORD, #4
  sta MAZE_X_COORD

  lda #(X_OFFSET * 4)
  jsr addOffset

  lda #EAST
  jsr draw
  jmp generateMaze

  

; needs direction in accumulator
; sets carry if cell is valid
; clears carry if cell is invalid
; cell is valid if:
;      - within screen boundary
;      - not yet already visited
; could use some optimization
isCellValid
  cmp #NORTH
  beq checkNorthCell
  cmp #SOUTH
  beq checkSouthCell
  cmp #EAST
  beq checkEastCell
checkWestCell
  dec_maze_coord MAZE_X_COORD, #4
  chk_scrn_bndry #LFT_SCRN_BNDRY
  bmi invalidCellValue

  lda #(X_OFFSET * 4)
  jsr subOffset

  ldy #0
  lda ($0),y
  tay

  lda #(X_OFFSET * 4)
  jsr addOffset
  jmp checkCellValue
checkEastCell
  inc_maze_coord MAZE_X_COORD, #4
  chk_scrn_bndry #RGHT_SCRN_BNDRY
  beq contEast
  bcs invalidCellValue

contEast
  lda #(X_OFFSET * 4)
  jsr addOffset

  ldy #0
  lda ($0),y
  tay

  lda #(X_OFFSET * 4)
  jsr subOffset
  jmp checkCellValue
checkNorthCell
  dec_maze_coord MAZE_Y_COORD, #4
  chk_scrn_bndry #TOP_SCRN_BNDRY
  bmi invalidCellValue

  lda #(Y_OFFSET * 4)
  jsr subOffset

  ldy #0
  lda ($0),y
  tay

  lda #(Y_OFFSET * 4)
  jsr addOffset
  jmp checkCellValue
checkSouthCell
  inc_maze_coord MAZE_Y_COORD, #4
  chk_scrn_bndry #BTM_SCRN_BNDRY
  beq contSouth
  bcs invalidCellValue
contSouth
  lda #(Y_OFFSET * 4)
  jsr addOffset

  ldy #0
  lda ($0),y
  tay

  lda #(Y_OFFSET * 4)
  jsr subOffset
checkCellValue
  cpy #CLEAR_CHAR
  bne invalidCellValue
validCellValue
  sec
  rts
invalidCellValue
  clc
  rts


; need to direction in accumulator
; returns direction in accumulator
rndDirection
  jsr random
  and #3
  rts

; random value returned in accumulator
random
  lda LFSR
  ldy LFSR
  lsr LFSR                ; 00010011 1  = 19
  lsr LFSR                ; 00001001 1  = 9
  eor LFSR    ; 6th tap   ; 00101110 1  = 46
  lsr LFSR                ; 00010111 1
  eor LFSR    ; 5th tap   ; 00110000 1
  lsr LFSR                ; 00011000 0
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
	lda	#CLEAR_CHAR
	ldx	#0
clrloop:	
  sta	$1e00,x
	sta	$1f00,x
	inx
	bne	clrloop
  rts


; needs move increment in accumulator
; uses x and accumulator
addOffset
  clc             ;2      ; clear the carry
  adc $0          ;3      ; add to LSB
  sta $0          ;3      ; store result in LSB
  lda #0          ;2
  adc $1          ;3      ; add carry to MSB
  sta $1          ;3      ; store MSB
  rts 

subOffset
  ldx $0
  sta $0           ; store offset into address (because large # - offset instead of offset - large #)
  TXA              ;3     ; load address into accumulator
  sec              ;2     ; set carry
  sbc $0           ;3     ; sub from LSB
  sta $0           ;3     ; store result in LSB
  lda $1           ;3
  sbc #0           ;2     ; add carry to MSB
  sta $1           ;3     ; store MSB
  rts

; needs character to draw in accumulator
draw
  ldy #0                ; looks pointless to load 0
  sta ($0),y            ; BUT IT NEEEDS IT
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
	cmp	#$20		; add delay
	bne	frame
  rts

drawPath
  ldy #0
  lda #102
  sta ($0),y
  iny
  sta ($0),y
  TYA
  CLC
  adc #21
  TAY
  lda #102
  sta ($0),y
  iny
  sta ($0),y
  rts