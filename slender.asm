; pg179 for character keys
; pg270 screen memory maps
; dont look at my garbage code - just accept it

	processor 6502

  INCLUDE "constants.asm"
  INCLUDE "macros.asm"

  org $1001
  DC.W end
  DC.W 1234
  DC.B $9e, " 4110", 0
end
  dc.w 0

initialization
  ldx #12								; ugly background
	stx 36879

  lda #SEED
  sta LFSR

  jsr clr

  jsr generateMaze

  jsr clr
  jsr startFrame
  jsr generateMaze

  include "maze.asm"