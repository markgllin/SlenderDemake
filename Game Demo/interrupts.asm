timer_IRQ:
	sei                     ; disable interrupts
        lda     VIA_CONTROL
        and     #$df            ; 1101 1111 - set timer 2 to one-shot-mode
        and     #$7f            ; 0111 1111 - clear first bit - disable PB7 (timer 1)
        ora     #$40            ; 0100 0000 - set second bit  - free running mode (timer 1)
        sta     VIA_CONTROL
        lda     #$e0            ; enable timer 1 and timer 2
        sta     VIA_ENABLE

        lda     #<isr_manager   ; get low byte of ISR address
        ; reference for this notation: page 204
        sta     IRQ_L
        lda     #>isr_manager   ; get high byte of ISR address
        sta     IRQ_H
        cli                     ; enable interrupts again
        rts

;;; ---- INTERRUPT SERVICE ROUTINES

isr_manager:
        pha                     ; save old A
        txa
        pha                     ; save old X
        tya
        pha                     ; save old Y
check_timer2:
        ;; check that the interrupt is happening from timer 2
        lda     VIA_FLAGS
        and     #$20            ; check TIMER2 bit ($20 = 0010 0000)
        beq     check_timer1    ; TIMER2 bit is NOT set
        jmp     isr_update_timer; TIMER2 bit is set
check_timer1:
        lda     VIA_FLAGS
        and     #$40            ; check TIMER1 bit ($40 = 0100 0000)
        beq     modulate        ; TIMER1 bit is not set either so modulate
        jmp     isr_update_music

modulate:                       ; modulate the notes
        lda     MOD_FLAG
        beq     zero_mod
one_mod:                        ; currently pointing at second "mod" note
        dec     MOD_FLAG        ; change to zero mod
        dec     S1_INDEX        ; point at first "mod" note
        dec     S3_INDEX
        jmp     done_mod
zero_mod:                       ; currently pointing at first  "mod" note
        inc     MOD_FLAG        ; change to one mod
        inc     S1_INDEX        ; point at second "mod" note
        inc     S3_INDEX
done_mod:
        jsr	play_notes

done_interrupt:
        pla
        tay                     ; restore old Y
        pla
        tax                     ; restore old X
        pla                     ; restore old A

        jmp     OLD_IRQ         ; continue on to old IRQ

;;;;;; END OF INTERRUPT HANDLER

;; update timer happens FIRST
isr_update_timer:
        ;; check end game condition in case it's already end game
        lda     GAME_STATUS
        beq     check_timer1

        ;; correct timer interrupt so do the thing
	jsr	start_timer2	; start by restarting the timer

        dec     TIMER_CTR
        lda     TIMER_CTR
        bne     check_timer1    ; counter is not zero

        ;; a second has passed
        lda     #NUM_SEC        ; reload counter
        sta     TIMER_CTR

        jsr     animate_sprite

isr_first_digit:                ; check the first figit (1 second)
        ldy     #$03
        lda     (SCRN_LSB),y
        cmp     #NUM_ZERO
        beq     isr_first_wrap_around
        sec
        sbc     #$01
        sta     (SCRN_LSB),y

        jmp     check_timer1

isr_first_wrap_around:		; first digit (1 second) wrapped around
        inc     NUM_WRAPS
        lda     #NUM_NINE
        sta     (SCRN_LSB),y
	
	;; check the second digit (10 seconds)
	check_wrap	#$02,isr_second_wrap_around	; MACRO
        jmp     check_timer1	; no wrap so get next IRQ

isr_second_wrap_around:		; second digit (10 seconds) wrapped around	
        inc     NUM_WRAPS
        lda     #NUM_NINE
        sta     (SCRN_LSB),y

	;; check the third digit (100 seconds)
	check_wrap	#$01,isr_third_wrap_around 	; MACRO
        jmp     check_timer1	; no wrap so get next IRQ

isr_third_wrap_around:	;	; third digit (100 seconds) wrapped around
        inc     NUM_WRAPS
        lda     NUM_WRAPS
        cmp     #$03		; check if timer reached 0000
        beq     isr_trigger_end_game

        lda     #$00            ; NOT end game so reset wraps
        sta     NUM_WRAPS
        lda     #NUM_NINE
        sta     (SCRN_LSB),y

        jmp     check_timer1	

isr_trigger_end_game:
        ;; reset timer to ZERO since wrap around for first
        ;; two digits already happened
        lda     #NUM_ZERO
        ldy     #02
        sta     (SCRN_LSB),y
        ldy     #03
        sta     (SCRN_LSB),y

        lda     #$0
        sta     GAME_STATUS

        jmp     check_timer1

;;; **** ISR : next_note
;;;      This ISR grabs the next note for each voice when timer 2 runs out
;;;  	 If the timer hasn't run out yet, modulate the note instead
isr_update_music:
	;;  restart the timer
        jsr	start_timer1

        dec     S1_DUR          ; single sixteenth note has passed
        bne     check_S3        ; if not zero, don't change the note and check next voice
change_S1:
        ;; move the S1 pointer to the next note
        next_note	S1_INDEX,S1NOTES	; MACRO
        cmp     #$ff
        beq     done_song        

	;; get duration for new note
	lda	MOD_FLAG
	bne	no_add_mod_S1
	inx
no_add_mod_S1:
	inx
	lda	S1NOTES,X
	sta	S1_DUR	
check_S3:
        dec     S3_DUR
        bne     done_notes      ; all voices checked; done
change_S3:                      ; else, change S3 note
        ;; move the S3 pointer to the next note
        next_note	S3_INDEX,S3NOTES	; MACRO

        ;; get duration for new note
	lda	MOD_FLAG
	bne	no_add_mod_S3
	inx
no_add_mod_S3:
	inx
	lda	S3NOTES,X
	sta	S3_DUR	

done_notes:                     ; we have checked all the notes
        jmp     modulate        ; modulate the notes

done_song:
        ;; restart the song from the beginning
    	jsr	restart_song
        jmp     done_mod

; --- SUBROUTINES

start_timer1:
	lda     #SIXT_L
        sta     TIMER1_L
        lda     #SIXT_H
        sta     TIMER1_H        ; STARTS the timer 1
	rts

start_timer2:
	lda     SECOND_L
        sta     TIMER2_L
        lda     SECOND_H
        sta     TIMER2_H        ; STARTS the timer 2 and clears the interrupt request
	rts
