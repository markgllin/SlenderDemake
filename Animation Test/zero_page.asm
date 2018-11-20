;;; ---- ZERO PAGE
SCRN_LSB    				= $00	 ; LSB of screen memory address
SCRN_MSB    				= $01	 ; MSB Of screen memory address	
CLRM_LSB    				= $04	 ; LSB of colour memory address
CLRM_MSB    				= $05	 ; MSB Of colour memory address
 
GAME_STATUS 				= $07	 ; if this is 0, end game
 
CURR_SPRITE 				= $08	 ; stores the starting character for current sprite
FRAME	   	  		        = $09	 ; frame counter for delays
CURR_CLR    				= $0a	 ; stores the current character colour
TIMER_CTR   				= $0b	 ; timer counter
NUM_WRAPS   				= $0c	 ; used to figure out end game condition
	               			         ; basically, counts the number of times the numbers wrap per decrement 
	               		                 ; If this reaches 3, then FULL WRAP AROUND so end game 
SPRITE_X 			= $0d
SPRITE_Y 			= $0e
SPRITE_PREV_X 			= $0f
SPRITE_PREV_Y 			= $10	
	

;; save the previous position of sprite incase invalid movement 
PREV_SPRITE_LSB     = $11	
PREV_SPRITE_MSB     = $12
PREV_SPRITE_CLR_LSB = $15
PREV_SPRITE_CLR_MSB = $16

;; current / proposed movement of sprite 
SPRITE_LSB	  = $18
SPRITE_MSB        = $19
SPRITE_CLR_LSB    = $1a
SPRITE_CLR_MSB    = $1b

LETTER_LSB 	  = $1e
LETTER_MSB	  = $1f
LETTER_CLR_LSB    = $20
LETTER_CLR_MSB	  = $21	

SCORE_LSB	  = $22
SCORE_MSB	  = $23

LFSR 		  = $24	

OFFSET            = $25
LSB               = $26
MSB               = $27

MAZE_X_COORD      = $28
MAZE_Y_COORD      = $29
MAZE_LSB          = $2a
MAZE_MSB          = $2b
MAZE_DIR          = $2c

TREE_CLR          = $2e
TREE_SPRITE       = $2f
TREE_CLR_LSB      = $30
TREE_CLR_MSB      = $31
TREE_LSB          = $32
TREE_MSB	  = $33

S1_INDEX          = $35
S1_DUR	  	  = $36
S3_INDEX  	  = $37
S3_DUR    	  = $39
MOD_FLAG  	  = $3a

ANIMATE_COUNT     = $3b
ANIMATE_STATUS    = $3d
