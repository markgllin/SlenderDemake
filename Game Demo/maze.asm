; maze setup
generateMaze subroutine
  lda #2           ; need to randomize this some how
  sta MAZE_X_COORD
  sta MAZE_Y_COORD

  lda #$2e         ; load LSB
  sta MAZE_LSB

  lda #$1e         ; load MSB
  sta MAZE_MSB

  lda #MAZE_ORIGIN
  sta $1e2e

.carveMaze
  jsr random
  and #3
  sta MAZE_DIR

  jsr isCellValid
  bcs .validCell
.invalidCell
  lda #NORTH
  jsr isCellValid
  bcs .carveMaze

  lda #SOUTH
  jsr isCellValid
  bcs .carveMaze

  lda #EAST
  jsr isCellValid
  bcs .carveMaze

  lda #WEST
  jsr isCellValid
  bcs .carveMaze

  jsr backtrack
  bcc .carveMaze
  jmp doneMaze
.validCell
  lda MAZE_DIR
  beq .updateNorthCell
  cmp #SOUTH
  beq .updateSouthCell
  cmp #EAST
  beq .updateEast
.updateWestCell
  dec_maze_coord MAZE_X_COORD, #4
  sta MAZE_X_COORD
  load_maze_offsets #(X_OFFSET * 2), subOffset
  store_maze_offsets
  jsr drawPath
  load_maze_offsets #(X_OFFSET * 2), subOffset
  ldx #WEST
  jmp .updateCell
.updateNorthCell
  dec_maze_coord MAZE_Y_COORD, #4
  sta MAZE_Y_COORD
  load_maze_offsets #(Y_OFFSET * 2), subOffset
  store_maze_offsets
  jsr drawPath
  load_maze_offsets #(Y_OFFSET * 2), subOffset
  ldx #NORTH
  jmp .updateCell
.updateEast
  jmp .updateEastCell
.updateSouthCell
  inc_maze_coord MAZE_Y_COORD, #4
  sta MAZE_Y_COORD
  load_maze_offsets #(Y_OFFSET * 2), addOffset
  store_maze_offsets
  jsr drawPath
  load_maze_offsets #(Y_OFFSET * 2), addOffset
  ldx #SOUTH
  jmp .updateCell
.updateEastCell
  inc_maze_coord MAZE_X_COORD, #4
  sta MAZE_X_COORD

  load_maze_offsets #(X_OFFSET * 2), addOffset
  store_maze_offsets
  jsr drawPath
  load_maze_offsets #(X_OFFSET * 2), addOffset
  ldx #EAST
.updateCell
  store_maze_offsets
  TXA
  jsr drawCell
  jmp .carveMaze

doneMaze subroutine
  jsr drawPath
  
  lda #MAZE_ENTRANCE_LSB
  sta MAZE_LSB
  lda #MAZE_ENTRANCE_MSB
  sta MAZE_MSB
  jsr drawPath

  lda #MAZE_EXIT_LSB
  sta MAZE_LSB
  lda #MAZE_EXIT_MSB
  sta MAZE_MSB
  jsr drawPath

  jsr maskTrees
	jsr place_letter
  rts

backtrack subroutine
  ldy #0
  lda (MAZE_LSB),y

  cmp #MAZE_ORIGIN
  beq .atOrigin

  TAX
  jsr drawPath
  TXA

  cmp #NORTH
  beq .bkTrackSouth
  cmp #SOUTH
  beq .bkTrackNorth
  cmp #EAST
  beq .bkTrackWest
.bkTrackEast
  inc_maze_coord MAZE_X_COORD, #4
  sta MAZE_X_COORD
  load_maze_offsets #(X_OFFSET * 4), addOffset
  jmp .updateAddress
.bkTrackSouth
  inc_maze_coord MAZE_Y_COORD, #4
  sta MAZE_Y_COORD

  load_maze_offsets #(Y_OFFSET * 4), addOffset
  jmp .updateAddress
.bkTrackNorth
  dec_maze_coord MAZE_Y_COORD, #4
  sta MAZE_Y_COORD

  load_maze_offsets #(Y_OFFSET * 4), subOffset
  jmp .updateAddress
.bkTrackWest
  dec_maze_coord MAZE_X_COORD, #4
  sta MAZE_X_COORD

  load_maze_offsets #(X_OFFSET * 4), subOffset
.updateAddress
  sta MAZE_MSB
  lda LSB
  sta MAZE_LSB
  clc
  rts
.atOrigin
  sec
  rts

isCellValid subroutine
  beq .checkNorthCell
  cmp #SOUTH
  beq .checkSouthCell
  cmp #EAST
  beq .checkEastCell

.checkWestCell
  dec_maze_coord MAZE_X_COORD, #4
  bmi .invalidCell

  load_maze_offsets #(X_OFFSET * 4), subOffset

  ldy #0
  lda (LSB),y
  jmp .checkCell

.checkNorthCell
  dec_maze_coord MAZE_Y_COORD, #4
  bmi .invalidCell

  load_maze_offsets #(Y_OFFSET * 4), subOffset

  ldy #0
  lda (LSB),y
  jmp .checkCell

.checkSouthCell
  inc_maze_coord MAZE_Y_COORD, #4
  cmp #BTM_SCRN_BNDRY
  beq .contSouth
  bcs .invalidCell
.contSouth
  load_maze_offsets #(Y_OFFSET * 4), addOffset

  ldy #0
  lda (LSB),y
  jmp .checkCell

.checkEastCell
  inc_maze_coord MAZE_X_COORD, #4
  cmp #RGHT_SCRN_BNDRY
  beq .contEast
  bcs .invalidCell
.contEast
  load_maze_offsets #(X_OFFSET * 4), addOffset

  ldy #0
  lda (LSB),y
.checkCell
  cmp #CLEAR_CHAR
  bne .invalidCell
.validCell
  sec
  rts
.invalidCell
  clc
  rts

drawPath subroutine
  ldy #0
  lda #PATH
  sta (MAZE_LSB),y
  iny
  sta (MAZE_LSB),y
  TYA
  CLC
  adc #21
  TAY
  lda #PATH
  sta (MAZE_LSB),y
  iny
  sta (MAZE_LSB),y
  rts

; needs character to draw in accumulator
drawCell subroutine
  ldy #0
  sta (MAZE_LSB),y
  rts

maskTrees subroutine
  lda #0
  sta MAZE_X_COORD
  sta MAZE_Y_COORD

  lda #$00         ; load LSB
  sta MAZE_LSB

  lda #$1e         ; load MSB
  sta MAZE_MSB

.drawTopLeft
  ldy #0

  lda (MAZE_LSB),y
  cmp #1
  beq .drawTopRight
  lda #CLEAR_CHAR_TL
  sta (MAZE_LSB),y
.drawTopRight
  iny

  lda (MAZE_LSB),y
  cmp #1
  beq .drawBottomLeft

  lda #CLEAR_CHAR_TR
  sta (MAZE_LSB),y

.drawBottomLeft
  TYA
  CLC
  adc #21
  TAY

  lda (MAZE_LSB),y
  cmp #1
  beq .drawBottomRight

  lda #CLEAR_CHAR_BL
  sta (MAZE_LSB),y
.drawBottomRight
  iny

  lda (MAZE_LSB),y
  cmp #1
  beq .drawNextBlock

  lda #CLEAR_CHAR_BR
  sta (MAZE_LSB),y

.drawNextBlock
  TYA
  CLC
  adc #2
  TAY
  lda MAZE_LSB
  ldx #2
  stx OFFSET
  ldx MAZE_MSB
  jsr addOffset
  sta MAZE_MSB
  lda LSB
  sta MAZE_LSB

  inc_maze_coord MAZE_X_COORD, #2
  cmp #RGHT_SCRN_BNDRY
  bcs .doneRow
  sta MAZE_X_COORD
  jmp .drawTopLeft
.doneRow
  inc_maze_coord MAZE_Y_COORD, #2
  cmp #BTM_SCRN_BNDRY
  bcs .doneDrawing
  sta MAZE_Y_COORD
  lda #0
  sta MAZE_X_COORD

  lda MAZE_LSB
  ldx #22
  stx OFFSET
  ldx MAZE_MSB
  jsr addOffset
  sta MAZE_MSB
  lda LSB
  sta MAZE_LSB

  jmp .drawTopLeft
.doneDrawing
  rts

checkDoorways subroutine
  lda SPRITE_Y
  cmp #MAZE_ENTRANCE_Y_COORD
  bne .keepMaze
.checkEntrance
  lda SPRITE_X
  cmp #22
  beq .newMazeRight
.checkExit
  cmp #0
  bne .keepMaze
.newMazeLeft
  lda #MAZE_ENTRANCE_X_COORD
  sta SPRITE_X

  lda #MAZE_ENTRANCE_LSB
  sta SPRITE_LSB
  sta SPRITE_CLR_LSB
  
  lda #MAZE_ENTRANCE_MSB
  sta SPRITE_MSB
  jmp .makeMaze
.newMazeRight
  lda #MAZE_EXIT_X_COORD
  sta SPRITE_X

  lda #MAZE_EXIT_LSB
  sta SPRITE_LSB
  sta SPRITE_CLR_LSB

  lda #MAZE_EXIT_MSB
  sta SPRITE_MSB
.makeMaze
  jsr clr
  jsr generateMaze
.keepMaze
  rts