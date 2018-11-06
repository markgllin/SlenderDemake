; CONSTANTS/VARIABLES

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GENERAL
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FRAME                 = $fb
CLEAR_CHAR            = 32
RASTER	              = $9004
NUMBERS_ADDRESS       = $1ca0		; where numbers start in custom charset

;; The timer runs at 1MHz so that means 1,000,000 cycles per second
;; Hence, we need to wait 1,000,000 = $000F 4240 cycles to wait a single second
;; That is, wait $f424 a total of $10 = 16 times.
SECOND_H	  = #$f4	; high byte of $f906
SECOND_L	  = #$24	; low  byte of $f906
NUM_SEC		  = #$11	; 1 MORE THAN how many ^ it takes for a single second

TIMER_CTR   = $0b	; timer counter
NUM_WRAPS   = $0c	; used to figure out end game condition
	                ; basically, counts the number of times the numbers wrap per decrement 
	                ; If this reaches 3, then FULL WRAP AROUND so end game 
GAME_STATUS = $0d	; if this is 0, end game

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; RNG/LFSR
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SEED                  = #240   ; can be anything but 0
LFSR                  = $24

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; KEYBOARD CONSTANTS/KERNEL CALLS
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SCAN_KEYBOARD         = $c5
W_KEY                 = 9
A_KEY                 = 17
S_KEY                 = 41
D_KEY                 = 18

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SCREEN CONSTANTS/VARIABLES
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LFT_SCRN_BNDRY      = 0
TOP_SCRN_BNDRY      = 0
RGHT_SCRN_BNDRY     = 21
BTM_SCRN_BNDRY      = 21

X_OFFSET            = 1
Y_OFFSET            = 22

OFFSET              = $20
LSB                 = $16
MSB                 = $17

AUX_C               = $900e     ; bits 4-7: auxillary colour
SCR_C               = $900f     ; bits 0-2: border color 
                                ; bits 4-7: background color
CHR_C               = $0286     ; character color (dec: 646)

COLOR_MEM           = $9600     ; start of colour memory 
SCRN_MEM1           = $1e00     ; start of screen memory
SCRN_MEM2           = $1f00     ; middle of screen memory
CHAR_MEM            = $1c00     ; start of character memory

SCRN_V              = $9001     ; vertical origin of the screen
ROWS	              = $9003     ; bits 1-6: number of rows (ref: p 175)

SCRN_LSB            = $00	      ; LSB of screen memory address
SCRN_MSB            = $01	      ; MSB Of screen memory address	
CLRM_LSB            = $04	      ; LSB of colour memory address
CLRM_MSB            = $05	      ; MSB Of colour memory address

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SPRITE VARIABLES/CONSTANTS
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; save the previous position of sprite incase invalid movement 
PREV_SPRITE_LSB     = $10	
PREV_SPRITE_MSB     = $11
PREV_SPRITE_CLR_LSB = $14
PREV_SPRITE_CLR_MSB = $15

;; current / proposed movement of sprite 
SPRITE_LSB	      = $18
SPRITE_MSB        = $19
SPRITE_CLR_LSB    = $1a
SPRITE_CLR_MSB    = $1b

SPRITE_START_LSB  = #$10 

CURR_SPRITE       = $08	; stores the starting character for current sprite
CURR_CLR          = $0a	; stores the current character colour

CHAR_FORWARD      = #$00	; character facing forward
CHAR_BCKWARD      = #$04	; character facing backward
CHAR_RIGHT        = #$08	; character facing to the right
CHAR_LEFT         = #$0c	; character facing to the left
TREE1             = #$10	
TREE_CLR          = $25
TREE_SPRITE       = $26
TREE_CLR_LSB      = $27
TREE_LSB          = $28
NUM_ZERO	        = #$14	; start of number 0
NUM_NINE	        = #$1d	; start of number 9 
	
SPRITE_CHAR_COLOR = #$09 	; multi-colour white
TREE_CHAR_COLOR   = #$0d	; multi-colour green

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MAZE VARIABLES
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MAZE_X_COORD        = $12
MAZE_Y_COORD        = $13
MAZE_LSB            = $21
MAZE_MSB            = $22
MAZE_ORIGIN         = 94
MAZE_DIR            = $23

NORTH               = 0   ;@
SOUTH               = 1   ;A
EAST                = 2   ;B
WEST                = 3   ;C

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; INTERRUPTS/TIMER VARIABLES
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; The IRQ vector is the location (ISR) to jump when an interrupt happens
IRQ_L        = $0314		; low byte of IRQ vector 
IRQ_H        = $0315		; high byte of IRQ vector 
OLD_IRQ      = $eabf
	
VIA_CONTROL  = $911b
VIA_FLAGS    = $911d		; reference: page 218
VIA_ENABLE   = $911e

TIMER1_LOC   = $9114		; timer 1 low order counter
TIMER1_HOC   = $9115		; timer 1 high order counter
TIMER1_LOL   = $9116		; timer 1 low order latch
TIMER1_HOL   = $9117		; timer 1 high order latch
	
TIMER2_L     = $9118		; timer 2 low order byte
TIMER2_H     = $9119		; timer 2 high order byte