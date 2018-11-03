; CONSTANTS/MACROS

FRAME = $fb

SEED                = #240   ; can be anything but 0
LFSR                = $3

OFFSET              = $4
LSB          = $5
MSB          = $6

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; KEYBOARD CONSTANTS/KERNEL CALLS
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SCAN_KEYBOARD = $c5
W_KEY = 9
A_KEY = 17
S_KEY = 41
D_KEY = 18

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SCREEN CONSTANTS/KERNEL CALLS
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SCRN_LEFT_BOUNDARY = 0
SCRN_TOP_BOUNDARY = 0
SCRN_RIGHT_BOUNDARY = 21
SCRN_BOTTOM_BOUNDARY = 22

X_OFFSET            = 1
Y_OFFSET            = 22

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MEM LOCATIONS OF SPRITE COORDS
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PLAYER_X = $0
PLAYER_Y = $1

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MAZE VARIABLES
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CLEAR_CHAR          = 32
MAZE_X_COORD        = $10
MAZE_Y_COORD        = $11
MAZE_LSB            = $0
MAZE_MSB            = $1
MAZE_ORIGIN         = 94
MAZE_DIR            = $2
LFT_SCRN_BNDRY      = 0
RGHT_SCRN_BNDRY     = 21
TOP_SCRN_BNDRY      = 0
BTM_SCRN_BNDRY      = 21

NORTH               = 0   ;@
SOUTH               = 1   ;A
EAST                = 2   ;B
WEST                = 3   ;C