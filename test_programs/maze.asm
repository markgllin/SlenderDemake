; pg179 for character keys
; pg270 screen memory maps
; dont look at my garbage code - just accept it
CHROUT = $ffd2
FRAME = $fb
X_COORD = $10
Y_COORD = $11
NORTH = 1   ;A
SOUTH = 2   ;B
EAST = 4    ;D
WEST = 8    ;H
CLOCK = $FFDE
LSB = $0
MSB = $1
TEMP = $2
X_OFFSET = 1
Y_OFFSET = 22
CLEAR_CHAR = 0
LEFT_SCREEN_BOUNDARY = 0
RIGHT_SCREEN_BOUNDARY = 21
TOP_SCREEN_BOUNDARY = 0
BOTTOM_SCREEN_BOUNDARY = 22
W_KEY = 9


	processor 6502
;;;;;;;;;;;;;;;;;;;;;;;;;;;
  mac checkScreenBoundary
  ldx [{1}]
  cpx [{2}]
  endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;
  mac peekCell
  ldy #0
  lda (LSB),y
  endm
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   mac checkNorthVisit
;   lda #22
;   jsr subOffset

;   peekCell
;   ora TEMP
;   sta TEMP
  
;   lda #22
;   jsr addOffset
;   endm
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   mac checkSouthVisit
;   lda #22
;   jsr addOffset

;   peekCell
;   ora TEMP
;   sta TEMP
  
;   lda #22
;   jsr subOffset
;   endm
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   mac checkEastVisit
;   lda #1
;   jsr addOffset

;   peekCell
;   ora TEMP
;   sta TEMP
  
;   lda #1
;   jsr subOffset
;   endm
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   mac checkWestVisit
;   lda #1
;   jsr subOffset

;   peekCell
;   ora TEMP
;   sta TEMP

;   lda #1
;   jsr addOffset
;   endm
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   mac isSurroundingVisited
;   lda #0
;   sta TEMP
;   checkEastVisit
;   checkWestVisit
;   checkNorthVisit
;   checkSouthVisit
;   endm
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;

  mac goDirection
  lda [{1}]
  jsr [{2}]
  endm

  mac goWest
  goDirection #X_OFFSET, subOffset
  endm

  mac goEast
  goDirection #X_OFFSET, addOffset
  endm

  mac goNorth
  goDirection #Y_OFFSET, subOffset
  endm

  mac goSouth
  goDirection #Y_OFFSET, addOffset
  endm

  org $1001
  DC.W end
  DC.W 1234
  DC.B $9e, " 4110", 0
end
  dc.w 0

  ldx #12								; ugly background
	stx 36879

  jsr clr               ; clear screen

  lda #$00              ; load LSB
  sta $0

  sta X_COORD                ; x-coord
  sta Y_COORD                ; y-coord

  lda #$1e              ; load MSB
  sta $1


input
  jsr startFrame
  lda $c5   ; current key pressed (pg 172)
  cmp #W_KEY      ;w
  beq up
  cmp #17     ;a
  beq left    
  cmp #41     ;s
  beq down
  cmp #18     ;d
  beq right
  jmp input
up
  lda #NORTH
  jsr isCellValid
  bcc input

  dex
  stx Y_COORD

  goNorth
  lda #NORTH
  jsr draw
  jmp input
down
  lda #SOUTH
  jsr isCellValid
  bcc input

  inx
  stx Y_COORD

  goSouth
  lda #SOUTH
  jsr draw
  jmp input
left
  lda #WEST
  jsr isCellValid
  bcc input
  dex
  stx $10

  goWest
  lda #WEST
  jsr draw
  jmp input
right
  lda #EAST
  jsr isCellValid
  bcc input

  inx
  stx $10 

  goEast
  lda #EAST
  jsr draw
  jmp input


; loop
;   jsr chooseRandomDirection
;   sta 7680
;   jmp loop

; choose random dir (not the way it came)
; check if direction is valid
;   direction is valid if:
;     - not yet visited / not a blank
;     - not beyond screen
;     - no visited nodes in at least 3 directions (not including blanks)
;   if valid:
;     - push onto stack/screen (marking it visited)
;     - update stack pointer
;     - jmp choose random dir
;   if not valid:
;     - check if any surrounding valid blocks
;       if yes:
;         choose random dir again
;       if no:
;         pop off stack (set current tile blank)
;         move back down stack (step back to previous tile)
;         choose random dir again

; this is not random but will use for now
chooseRandomDirection
  ;choose random dir
  jsr CLOCK           ; random value stored in accumulator
  cmp #192
  bcs north
  cmp #128
  bcs south
  cmp #64
  bcs east
west
  lda #WEST
  rts
north
  lda #NORTH
  rts
south
  lda #SOUTH
  rts
east
  lda #EAST
  rts


; needs direction in accumulator
isInScreenBoundary
  cmp #NORTH
  beq checkNorth
  cmp #SOUTH
  beq checkSouth
  cmp #EAST
  beq checkEast
checkWest
  checkScreenBoundary X_COORD, #LEFT_SCREEN_BOUNDARY
  beq invalidScreenBoundary
  jmp validScreenBoundary
checkNorth
  checkScreenBoundary Y_COORD, #TOP_SCREEN_BOUNDARY
  beq invalidScreenBoundary
  jmp validScreenBoundary
checkSouth
  checkScreenBoundary Y_COORD, #BOTTOM_SCREEN_BOUNDARY
  beq invalidScreenBoundary
  jmp validScreenBoundary
checkEast
  checkScreenBoundary X_COORD, #RIGHT_SCREEN_BOUNDARY
  beq invalidScreenBoundary
validScreenBoundary
  sec
  rts
invalidScreenBoundary
  clc
  rts

; needs direction in accumulator
isVisitedCell
  cmp #NORTH
  beq loadNorthOffset
  cmp #SOUTH
  beq loadSouthOffset
  cmp #EAST
  beq loadEastOffset
loadWestOffset
  goWest

  peekCell
  TAY

  goEast

  cpy #CLEAR_CHAR
  bne invalidVisited
  jmp validUnvisited
loadNorthOffset
  goNorth

  peekCell
  TAY

  goSouth

  cpy #CLEAR_CHAR
  bne invalidVisited
  jmp validUnvisited
loadSouthOffset
  goSouth

  peekCell
  TAY
  
  goNorth

  cpy #CLEAR_CHAR
  bne invalidVisited
  jmp validUnvisited
loadEastOffset
  goEast

  peekCell
  TAY

  goWest

  cpy #CLEAR_CHAR
  bne invalidVisited
validUnvisited
  sec
  rts
invalidVisited
  clc
  rts


; needs direction to be pass in by accumulator
; affects A, X, Y registers
isCellValid
  sta TEMP
  jsr isInScreenBoundary
  bcc notValid

  lda TEMP
  jsr isVisitedCell
  bcc notValid

  ; lda TEMP
  ; jsr areSurroundingCellsVisited
  ; bcc notValid
isValid
  sec
  rts
notValid
  clc
  rts

areSurroundingCellsVisited
; no visited nodes in the 3 directions (not including blanks)
  cmp #NORTH
  beq setNorthOffset
  cmp #SOUTH
  beq setSouthOffset
  cmp #EAST
  beq setEastOffset
setWestOffset
  goWest
  jsr countSurroundingCells
  goEast
  jmp checkVisited
setNorthOffset
  goNorth
  jsr countSurroundingCells
  goSouth
  jmp checkVisited
setSouthOffset
  goSouth
  jsr countSurroundingCells
  goNorth
  jmp checkVisited
setEastOffset
  goEast
  jsr countSurroundingCells
  goWest
checkVisited
  ldy TEMP
  cpy #1
  bmi invalidSurroundingCells
validSurroundingCells
  sec
  rts
invalidSurroundingCells
  clc
  rts


countSurroundingCells
  ldy #0
  sty TEMP
checkLeft
  checkScreenBoundary #X_COORD, #LEFT_SCREEN_BOUNDARY ; check if surrounding cell is on screen edge
  bcs incrementLeft      ; branch to incrementLeft if on scrn boundary
  lda #WEST
  jsr isVisitedCell
  bcc checkRight         ; branch if valid cell
incrementLeft
  inc TEMP
checkRight
  checkScreenBoundary #X_COORD, #RIGHT_SCREEN_BOUNDARY
  bcs incrementRight      ; branch to incrementLeft if on scrn boundary
  lda #EAST
  jsr isVisitedCell
  bcc checkTop
incrementRight
  inc TEMP
checkTop
  checkScreenBoundary #Y_COORD, #TOP_SCREEN_BOUNDARY
  bcs incrementTop      ; branch to incrementLeft if on scrn boundary
  lda #NORTH
  jsr isVisitedCell
  bcc checkTop
incrementTop
  inc TEMP
checkBottom
  checkScreenBoundary #Y_COORD, #BOTTOM_SCREEN_BOUNDARY
  bcs incrementBottom      ; branch to incrementLeft if on scrn boundary
  lda #SOUTH
  jsr isVisitedCell
  bcc doneCount
incrementBottom
  inc TEMP
doneCount
  rts

pushScreen
  ; mark visited by setting direction
  ; update current stack pointer + coord
  ; jmp to choose another random dir

popScreen
  ; set current tile blank
  ; move back down stack (step back to previous tile)
  ; jmp to choose another random dir



  ; print to screen
  ; move to new tile


; needs move increment in accumulator
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
  TXA           ;3     ; load address into accumulator
  sec              ;2     ; set carry
  sbc $0           ;3     ; sub from LSB
  sta $0           ;3     ; store result in LSB

  lda $1           ;3
  sbc #0           ;2     ; add carry to MSB
  sta $1           ;3     ; store MSB
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

startFrame	
  lda	#$00
	sta	FRAME	
frame	
  lda	$9004		; raster beam line number
	cmp	#$0		; top of the screen
	bne frame
	inc	FRAME		; increase frame counter
	lda	FRAME
	cmp	#$10		; add delay
	bne	frame
  rts

draw
  ;lda #0                ; load @
load
  ldy #0                ; looks pointless to load 0
  sta ($0),y            ; BUT IT NEEEDS IT
  rts