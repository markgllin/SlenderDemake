	;; set up the new IRQ vector for timer 2
timer2_IRQ:
	lda	VIA_CONTROL
	and	#$df	 	; set timer 2 to one-shot-mode
	sta	VIA_CONTROL

	lda	#$a0 		; enable timer 2
	sta 	VIA_ENABLE
	
	sei			; disable interrupts

	lda	#<isr_check_irq	; get low byte of ISR address
				; reference for this notation: page 204
	sta	IRQ_L
	lda	#>isr_check_irq	; get high byte of ISR address
	sta	IRQ_H

	cli			; enable interrupts again
	rts

;;; ---- INTERRUPT SERVICE ROUTINES

isr_check_irq:
	pha			; save old A
	txa
	pha			; save old X
	tya
	pha			; save old Y

	;; check that the interrupt is happening from timer 2
	lda	VIA_FLAGS
	and	#$20		; check TIMER2 bit ($20 = 0010 0000)
	bne	isr_timer2	; TIMER2 bit is set
	jmp	isr_done_timer2 ; TIMER2 did NOT cause the IRQ
	
isr_timer2:
	;; check end game condition in case it's already end game
	lda	GAME_STATUS
	bne	isr_not_endgame	
	jmp	isr_done_timer2

isr_not_endgame:
	;; start by restarting the timer 
	lda	SECOND_L
	sta	TIMER2_L	
	lda	SECOND_H
	sta	TIMER2_H	; STARTS the timer and clears the interrupt request

	dec	TIMER_CTR
	lda	TIMER_CTR
	beq	isr_second_passed
	jmp	isr_done_timer2

isr_second_passed:
	;; a second has passed
	lda	#NUM_SEC	; reload counter
	sta	TIMER_CTR

isr_first_digit:		; check the seconds digit
	ldy	#$03
	lda	(SCRN_LSB),y
	cmp	#NUM_ZERO
	beq	isr_first_wrap_around

	sec
	sbc	#$01	
	sta	(SCRN_LSB),y
	jmp	isr_update_music
	
isr_first_wrap_around:
	inc	NUM_WRAPS
	
	lda	#NUM_NINE
	sta	(SCRN_LSB),y

	ldy	#$02		; check second digit
	lda	(SCRN_LSB),y
	cmp	#NUM_ZERO
	beq	isr_second_wrap_around

	sec
	sbc	#$01
	sta	(SCRN_LSB),y
	jmp	isr_update_music
	
isr_second_wrap_around:	
	inc	NUM_WRAPS
	
	lda	#NUM_NINE
	sta	(SCRN_LSB),y
	
	ldy	#$01		; check third digit
	lda	(SCRN_LSB),y
	cmp	#NUM_ZERO
	beq	isr_third_wrap_around

	sec
	sbc	#$01
	sta	(SCRN_LSB),y
	jmp	isr_update_music

isr_third_wrap_around:
	inc	NUM_WRAPS
	lda	NUM_WRAPS
	cmp	#$03
	beq	isr_trigger_end_game

	lda	#$00		; NOT end game so reset wraps
	sta	NUM_WRAPS	
	lda	#NUM_NINE
	sta	(SCRN_LSB),y
	jmp	isr_update_music

isr_trigger_end_game:
	;; reset timer to ZERO since wrap around for first
	;; two digits already happened
	lda	#NUM_ZERO
	ldy	#02
	sta	(SCRN_LSB),y
	ldy	#03
	sta	(SCRN_LSB),y
	
	lda	#$0
	sta	GAME_STATUS
	
isr_update_music:
	dec	S1_DUR		; single sixteenth note has passed
	bne	isr_check_S3	; if not zero, don't change the note and check next voice
isr_change_S1:	
	;; move the S1 pointer to the next note
	ldx	S1_INDEX
	inx
	inx
	inx
	lda	S1NOTES,X
	cmp	#$ff
	beq 	isr_done_song
	stx	S1_INDEX

	;; get duration for new note
	lda	MOD_FLAG
	beq	add_mod
	inx
	lda	S1NOTES,X
	sta	S1_DUR
isr_check_S3:
	dec	S3_DUR
	bne 	isr_done_notes	; all voices checked; done
isr_change_S3:			; else, change S3 note
	;; move the S3 pointer to the next note
	ldx	S3_INDEX
	inx
	inx
	inx
	lda	S3NOTES,X
	stx	S3_INDEX

	;; get duration for new note
	lda	MOD_FLAG
	beq	add_mod
	inx
	lda	S3NOTES,X
	sta	S3_DUR
isr_done_notes:			; we have checked all the notes
	jmp	modulate	; modulate the notes

isr_done_song:
	;; restart the song from the beginning
	lda	#0
	sta	S1_INDEX
	sta	S3_INDEX
	sta	MOD_FLAG
	
	lda	S1NOTES + 2
	sta	S1_DUR
	lda	S3NOTES + 2
	sta	S3_DUR

	jmp 	done_mod

modulate:			; modulate the notes
	lda	MOD_FLAG
	beq	zero_mod
one_mod:			; currently pointing at second "mod" note
	dec	MOD_FLAG	; change to zero mod
	dec	S1_INDEX	; point at first "mod" note
	dec	S3_INDEX
	jmp	done_mod
zero_mod:			; currently pointing at first  "mod" note
	inc	MOD_FLAG	; change to one mod
	inc	S1_INDEX	; point at second "mod" note
	inc	S3_INDEX
done_mod:
	ldx	S1_INDEX
	lda	S1NOTES,X
	sta	S1		; load the new note and play it
	ldx	S3_INDEX
	lda	S3NOTES,X
	sta	S3

isr_done_timer2:
	pla
	tay			; restore old Y
	pla
	tax			; restore old X
	pla			; restore old A
	
	jmp	OLD_IRQ

add_mod:
	inx
	rts
