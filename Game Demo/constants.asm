;;; ---- ADDRESSES
AUX_C             = $900e   ; bits 4-7: auxillary colour
SCR_C             = $900f   ; bits 0-2: border color 
                                  ; bits 4-7: background color
CHR_C             = $0286   ; character color (dec: 646)

COLOR_MEM         = $9600   ; start of colour memory 
SCRN_MEM1         = $1e00   ; start of screen memory
SCRN_MEM2         = $1f00   ; middle of screen memory
CHAR_MEM          = $1c00   ; start of character memory

SCRN_V            = $9001   ; vertical origin of the screen
ROWS	            = $9003   ; bits 1-6: number of rows (ref: p 175)
RASTER	          = $9004

;; The IRQ vector is the location (ISR) to jump when an interrupt happens
IRQ_L             = $0314		; low byte of IRQ vector 
IRQ_H             = $0315		; high byte of IRQ vector 
OLD_IRQ           = $eabf
	
VIA_CONTROL       = $911b
VIA_FLAGS         = $911d		; reference: page 218
VIA_ENABLE        = $911e

TIMER1_LOC        = $9114		; timer 1 low order counter
TIMER1_HOC        = $9115		; timer 1 high order counter
TIMER1_LOL        = $9116		; timer 1 low order latch
TIMER1_HOL        = $9117		; timer 1 high order latch
	
TIMER2_L          = $9118		; timer 2 low order byte
TIMER2_H          = $9119		; timer 2 high order byte

;;; CUSTOM CHARSET ADDRESSES
SPACE_ADDRESS     = $1c00   ; where the space character starts
SPRITE_ADDRESS    = $1c30		; where the sprites start
NUMBERS_ADDRESS   = $1ce0		; where numbers start in custom charset
	

;;; ---- CONSTANTS
SPACE             = #$00    ; @
CHAR_FORWARD      = #$06    ; A = character facing forward
CHAR_BCKWARD      = #$0a    ; E = character facing backward
CHAR_RIGHT        = #$0e    ; I = character facing to the right
CHAR_LEFT         = #$12    ; M = character facing to the left
TREE1             = #$16    ; Q = tree sprite  
ITEM_LETTER	      = #$1a    ; U = letter sprite
NUM_ZERO	        = #$1c    ; W = start of number 0
NUM_NINE	        = #$25    ; SPACE = start of number 9 

SPRITE_CHAR_COLOR = #$09   	; multi-colour white
TREE_CHAR_COLOR   = #$0d   	; multi-colour green

;; The timer runs at 1MHz so that means 1,000,000 cycles per second
;; Hence, we need to wait 1,000,000 = $000F 4240 cycles to wait a single second
;; That is, wait $f424 a total of $10 = 16 times.
SECOND_H	        = #$f4    ; high byte of $f906
SECOND_L	        = #$24    ; low  byte of $f906
NUM_SEC		        = #$11    ; 1 MORE THAN how many ^ it takes for a single second

CLEAR_CHAR        = 0

LFT_SCRN_BNDRY    = 0
TOP_SCRN_BNDRY    = 0
RGHT_SCRN_BNDRY   = 21
BTM_SCRN_BNDRY    = 21

X_OFFSET          = 1
Y_OFFSET          = 22

MAZE_ORIGIN       = 94

MAZE_ENTRANCE_LSB = #$dc
MAZE_ENTRANCE_MSB = #$1e
MAZE_EXIT_LSB     = #$f0
MAZE_EXIT_MSB     = #$1e

NORTH             = 1 
SOUTH             = 2 
EAST              = 3 
WEST              = 4 
PATH              = 1

CLEAR_CHAR_TL     = 2
CLEAR_CHAR_TR     = 3
CLEAR_CHAR_BL     = 4
CLEAR_CHAR_BR     = 5

SCAN_KEYBOARD     = $c5
W_KEY             = 9
A_KEY             = 17
S_KEY             = 41
D_KEY             = 18

SEED              = 240     ; can be anything but 0