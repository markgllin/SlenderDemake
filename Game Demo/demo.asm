        processor 6502

        INCLUDE "constants.asm"
        INCLUDE "zero_page.asm"
        INCLUDE "macros.asm"

        org     $1001

        dc.w    end
        dc.w    1234
        dc.b    $9e, " 4110", 0
end:
        dc.w    0

	lda     #255            ; custom character set
        sta     $9005
	lda	28
	sta	56
	sta	58

        ;; set up the interrupts
	jsr	start_screen
        jsr     timer_IRQ
start:
        lda     #14             ; border blue, screen black (ref p. 265)
        sta     SCR_C
        lda     #$7f            ; yellow = first four bits = 7 (ref p. 264)
        ; volume = other four bits = f
        ; 7f = 0111 1111 where 111 = 7 and 1111 = f
        sta     AUX_C

        ;; load zeros into the "0" character of our custom charset
        ldx     #$00
        lda     #$00
copy_blank:
        sta     SPACE_ADDRESS,X
        inx
        cpx     #48
        bne     copy_blank

; ; COMMENT out copy_blank and uncomment copy_blank_debug
; ; and copy_blank2_debug to debug with maze visible
; ; copy_blank3_debug is only for seeing area beyond path - can ignore for the most part
; copy_blank_debug:
; 	sta	SPACE_ADDRESS,X
; 	inx
; 	cpx	#8
; 	bne	copy_blank_debug

; 	lda	#$ff
; copy_blank2_debug:
; 	sta	SPACE_ADDRESS,X
; 	inx
; 	cpx	#16
; 	bne	copy_blank2_debug

; 	lda	#$00
; copy_blank3_debug:
; 	sta	SPACE_ADDRESS,X
; 	inx
; 	cpx	#48
; 	bne	copy_blank3_debug

        ;; character sprites = first 256 bytes
        ldx     #00
copy_sprites:
        lda     sprite,X
        sta     SPRITE_ADDRESS,X
        inx
        bne     copy_sprites

        ;; copy remaining 48 bytes (tree and letter)
        ; ldx     #00     ---> x is already 0 from above
copy_others:
        lda     tree1,X
        sta     TREE_ADDRESS,X
        inx
        cpx     #$30            ; 48
        bne     copy_others

        ;; copy the numbers from memory
        ;; a.k.a copy starting from $8000 + ($30 * 8) = $8000 + $180 = $8180
        ;; Copy all 10 characters: 10 * 8 = 80 = $50 bytes to copy
        ldx     #$0
copy_numbers:
        lda     $8180,X         ; copy the source to the destination
        sta     NUMBERS_ADDRESS,X	; end of sprites
        inx
        cpx     #$50            ; copy characters 0-9
        bne     copy_numbers

init_all_the_things:
        ;; load 0 everywhere that needs it
        lda     #$00            
        sta     SCRN_LSB
        sta     CLRM_LSB
	sta     NUM_WRAPS
	sta     ANIMATE_STATUS
	sta	GAME_STATUS	; if non-zero, then end the game
        sta     LETTER_STATE

        lda     #$12		; 4 characters away from right top corner
        sta     SCORE_LSB	; position of the score on screen 

        lda     #$1e            ; load MSB
        sta     SCRN_MSB
        sta     SPRITE_MSB
        sta     SCORE_MSB

        lda     #$96
        sta     CLRM_MSB
        sta     SPRITE_CLR_MSB
        
	;; init the position of the sprite at spawn
        lda     #$03
        sta     SPRITE_X
        lda     #$01
        sta     SPRITE_Y
        
        ;; init starting room
        sta     CURR_ROOM

        lda     #ANIMATION_DELAY
        sta     ANIMATE_COUNT 	; controls animation of sprite

        lda     #NUM_SEC
        sta     TIMER_CTR	; when 0, a second has passed

        ;; init all the music things
        jsr	restart_song
	jsr	play_notes

        ;; initialize the timer to 0300 and the score to 0000
        ldx     #$0
init_timer_and_score_loop:
	; font colour should still be white from start screen
        lda     #NUM_ZERO        ; number 0
        sta     TIMER_ADDRESS,X  ; position of timer
	sta	SCORE_ADDRESS,X  ; position of score
	lda	#01
	sta	$9600,X
        inx
        cpx     #$04
        bne     init_timer_and_score_loop

	;; make timer 0300 instead of 0000 from init above
        ldy     #$01		; third digit
	; ldy	#$03		; for debug of end screen - make it 3 seconds instead of 300
        lda     #NUM_ZERO + 3   ; number 3
        sta     TIMER_ADDRESS,y

	;; check win condition by automatically setting score
	; ldy     #$00		    ; fourth digit
        ; lda     #NUM_ZERO + 1     ; number 1
        ; sta     SCORE_ADDRESS,y

        jsr     random
        sta     ROOM_SEED

place_character_sprite:
        jsr     generateMaze
        lda     #$2e            ; offset sprite
        sta     SPRITE_LSB
        sta     SPRITE_CLR_LSB

        lda     #SPRITE_CHAR_COLOR
        sta     CURR_CLR
        lda     #CHAR_FORWARD
        sta     CURR_SPRITE
        draw_char CURR_SPRITE, CURR_CLR, SPRITE_CLR_LSB, SPRITE_LSB

	jsr     draw_env	; draw environment around sprite

start_timers:
        jsr	start_timer1
	jsr	start_timer2

;;; ----- INPUT
input:
        ;; check game status FIRST
        lda     GAME_STATUS
        beq     continue_game
        jsr     end_game

continue_game:
        ;; not end game so continue
        ldx     #$00
        stx     FRAME
.frame:
        lda     RASTER          ; raster beam line number
        bne     .frame
        inx                ; increase frame counter
        cpx     #$19            ; add delay
        bne     .frame
        
        lda     SCAN_KEYBOARD
        cmp     #W_KEY
        beq     up
        cmp     #A_KEY
        beq     left
        cmp     #S_KEY
        beq     down
        cmp     #D_KEY
        beq     right
        jmp     input
up:
        jsr     erase
        ldy     #22
        jsr     subSpriteOffset
        dec     SPRITE_Y

        lda     #CHAR_BCKWARD
        sta     CURR_SPRITE

        jmp     doneInput
down:
        jsr     erase
        ldy     #$16
        jsr     addSpriteOffset
        inc     SPRITE_Y

        lda     #CHAR_FORWARD
        sta     CURR_SPRITE
        jmp     doneInput
left:
        jsr     erase
        ldy     #1
        jsr     subSpriteOffset
        dec     SPRITE_X

        lda     #CHAR_LEFT
        sta     CURR_SPRITE
        jsr     checkDoorways
        jmp     doneInput
right
        jsr     erase
        ldy     #1
        jsr     addSpriteOffset
        inc     SPRITE_X

        lda     #CHAR_RIGHT
        sta     CURR_SPRITE
        jsr     checkDoorways
doneInput:
        lda     #$00
        sta     ANIMATE_STATUS

        jsr     check_movement
        ;jsr debugCoordinates
        draw_char CURR_SPRITE, CURR_CLR, SPRITE_CLR_LSB, SPRITE_LSB
        jsr     draw_env
        jmp     input

;;; ----- END GAME

end_game:
        jmp     end_screen

        INCLUDE "maze.asm"
        INCLUDE "common_subroutines.asm"
        INCLUDE "movement.asm"
        INCLUDE "interrupts.asm"
        INCLUDE "sprites.asm"
        INCLUDE "music.asm"
	INCLUDE	"end_screen.asm"
	INCLUDE "start_screen.asm"  ;;; this MUST be last unless you want bad things to happen
