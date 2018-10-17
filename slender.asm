; pg179 for character keys
; pg270 screen memory maps
; dont look at my garbage code - just accept it
CHROUT = $ffd2
FRAME = $fb


	processor 6502
  org $1001
  DC.W end
  DC.W 1234
  DC.B $9e, " 4110", 0
end
  dc.w 0

  INCLUDE "constants.asm"