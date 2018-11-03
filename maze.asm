  processor 6502

  include "constants.asm"
  include "macros.asm"

  org $1001
  DC.W end
  DC.W 1234
  DC.B $9e, " 4110", 0
end
  dc.w 0

  ldx #12								; ugly background
	stx 36879

  jsr clr

  lda #2                ; need to randomize this some how
  sta MAZE_X_COORD
  sta MAZE_Y_COORD

  lda #$2e         ; load LSB
  sta MAZE_LSB

  lda #$1e         ; load MSB
  sta MAZE_MSB

  lda #MAZE_ORIGIN
  sta $1e2e

  lda #SEED
  sta LFSR

beginMaze
  jsr startFrame

  jsr random
  and #3
  sta MAZE_DIR

  jsr isCellValid
  bcs validCell
invalidCell
  lda #NORTH
  jsr isCellValid
  bcs beginMaze

  lda #SOUTH
  jsr isCellValid
  bcs beginMaze

  lda #EAST
  jsr isCellValid
  bcs beginMaze

  lda #WEST
  jsr isCellValid
  bcs beginMaze

  jsr backtrack
  bcc beginMaze
  jmp doneMaze

validCell
  lda MAZE_DIR
  beq updateNorthCell
  cmp #SOUTH
  beq updateSouthCell
  cmp #EAST
  beq updateEast
updateWestCell
  dec_maze_coord MAZE_X_COORD, #4
  sta MAZE_X_COORD
  load_maze_offsets #(X_OFFSET * 2), subOffset
  store_maze_offsets
  ;ldx #WEST
  jsr drawPath
  load_maze_offsets #(X_OFFSET * 2), subOffset
  ldx #WEST
  jmp updateCell
updateNorthCell
  dec_maze_coord MAZE_Y_COORD, #4
  sta MAZE_Y_COORD
  load_maze_offsets #(Y_OFFSET * 2), subOffset
  store_maze_offsets
  ;ldx #NORTH
  jsr drawPath
  load_maze_offsets #(Y_OFFSET * 2), subOffset
  ldx #NORTH
  jmp updateCell
updateEast
  jmp updateEastCell
updateSouthCell
  inc_maze_coord MAZE_Y_COORD, #4
  sta MAZE_Y_COORD
  load_maze_offsets #(Y_OFFSET * 2), addOffset
  store_maze_offsets
  ;ldx #SOUTH
  jsr drawPath
  load_maze_offsets #(Y_OFFSET * 2), addOffset
  ldx #SOUTH
  jmp updateCell
updateEastCell
  inc_maze_coord MAZE_X_COORD, #4
  sta MAZE_X_COORD

  load_maze_offsets #(X_OFFSET * 2), addOffset
  store_maze_offsets
  ;ldx #EAST
  jsr drawPath
  load_maze_offsets #(X_OFFSET * 2), addOffset
  ldx #EAST
updateCell
  store_maze_offsets
  TXA
  jsr draw
  jmp beginMaze

doneMaze
  jsr drawPath
  jmp doneMaze


backtrack
  ldy #0
  lda (MAZE_LSB),y

  cmp #MAZE_ORIGIN
  beq atOrigin

  TAX
  jsr drawPath
  TXA

  cmp #NORTH
  beq bkTrackSouth
  cmp #SOUTH
  beq bkTrackNorth
  cmp #EAST
  beq bkTrackWest
bkTrackEast
  inc_maze_coord MAZE_X_COORD, #4
  sta MAZE_X_COORD
  load_maze_offsets #(X_OFFSET * 4), addOffset
  jmp updateMazeAddr
bkTrackSouth
  inc_maze_coord MAZE_Y_COORD, #4
  sta MAZE_Y_COORD

  load_maze_offsets #(Y_OFFSET * 4), addOffset
  jmp updateMazeAddr
bkTrackNorth
  dec_maze_coord MAZE_Y_COORD, #4
  sta MAZE_Y_COORD

  load_maze_offsets #(Y_OFFSET * 4), subOffset
  jmp updateMazeAddr
bkTrackWest
  dec_maze_coord MAZE_X_COORD, #4
  sta MAZE_X_COORD

  load_maze_offsets #(X_OFFSET * 4), subOffset
updateMazeAddr
  sta MAZE_MSB
  lda LSB
  sta MAZE_LSB
  clc
  rts
atOrigin
  sec
  rts

isCellValid
  beq checkNorthCell
  cmp #SOUTH
  beq checkSouthCell
  cmp #EAST
  beq checkEastCell

checkWestCell
  dec_maze_coord MAZE_X_COORD, #4
  bmi invalidCellValue

  load_maze_offsets #(X_OFFSET * 4), subOffset

  ldy #0
  lda (LSB),y
  jmp checkCellValue

checkNorthCell
  dec_maze_coord MAZE_Y_COORD, #4
  bmi invalidCellValue

  load_maze_offsets #(Y_OFFSET * 4), subOffset

  ldy #0
  lda (LSB),y
  jmp checkCellValue

checkSouthCell
  inc_maze_coord MAZE_Y_COORD, #4
  cmp #BTM_SCRN_BNDRY
  beq contSouth
  bcs invalidCellValue
contSouth
  load_maze_offsets #(Y_OFFSET * 4), addOffset

  ldy #0
  lda (LSB),y
  jmp checkCellValue

checkEastCell
  inc_maze_coord MAZE_X_COORD, #4
  cmp #RGHT_SCRN_BNDRY
  beq contEast
  bcs invalidCellValue
contEast
  load_maze_offsets #(X_OFFSET * 4), addOffset

  ldy #0
  lda (LSB),y
checkCellValue
  cmp #CLEAR_CHAR
  bne invalidCellValue
validCellValue
  sec
  rts
invalidCellValue
  clc
  rts

drawPath
  ldy #0
  lda #102
  sta (MAZE_LSB),y
  iny
  sta (MAZE_LSB),y
  TYA
  CLC
  adc #21
  TAY
  lda #102
  sta (MAZE_LSB),y
  iny
  sta (MAZE_LSB),y
  rts

; needs LSB in accumulator and MSB in X
; needs offset in OFFSET
; returns values in OFFSET, LSB, AND MSB
; also returns MSB accumulator
addOffset
  clc                             ; clear the carry
  adc OFFSET                ; add to LSB
  sta LSB                ; store result in LSB
  TXA          
  adc #0            ; add carry to MSB
  sta MSB            ; store MSB
  rts 

; needs LSB in accumulator and MSB in X
; needs offset in OFFSET
; returns values in OFFSET, LSB, AND MSB
; also returns MSB accumulator
subOffset
  sec
  sbc OFFSET
  sta LSB
  TXA
  sbc #0
  sta MSB
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

; random value returned in accumulator
; alters Y register
random
  lda LFSR
  ldy LFSR
  lsr LFSR              
  lsr LFSR              
  eor LFSR    ; 6th tap 
  lsr LFSR             
  eor LFSR    ; 5th tap
  lsr LFSR             
  eor LFSR    ; 4th tap
  and #1               
  sty LFSR
  lsr LFSR
  clc
  ror
  ror                  
  ora LFSR             
  sta LFSR
  rts

  ; needs character to draw in accumulator
draw
  ldy #0                ; looks pointless to load 0
  sta (MAZE_LSB),y            ; BUT IT NEEEDS IT
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