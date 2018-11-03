; MACROS

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;
; loads coordinate into [{1}] and subtracts [{2}]
; result stored in accumulator
  mac load_maze_offsets
  lda [{1}]
  sta OFFSET
  lda MAZE_LSB
  ldx MAZE_MSB
  jsr [{2}]
  endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;