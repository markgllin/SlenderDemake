	;; set up the new IRQ vector for timer 2
timer2_IRQ:
	lda	VIA_CONTROL
	and	#$df	 	; set timer 2 to one-shot-mode
	sta	VIA_CONTROL

	lda	#$a0 		; enable timer 2
	sta 	VIA_ENABLE
	
	sei			; disable interrupts

	lda	#<isr_update_timer	; get low byte of ISR address
				; reference for this notation: page 204
	sta	IRQ_L
	lda	#>isr_update_timer	; get high byte of ISR address
	sta	IRQ_H

	cli			; enable interrupts again
	rts

;;; ---- INTERRUPT SERVICE ROUTINES

isr_update_timer:
	pha			; save old A
	txa
	pha			; save old X
	tya
	pha			; save old Y

	;; check that the interrupt is happening from timer 2
	lda	VIA_FLAGS
	and	#$20		; check TIMER2 bit ($20 = 0010 0000)
	beq	isr_done_update	; TIMER2 bit is not set so different interrupt

	;; check end game condition in case it's already end game
	lda	GAME_STATUS
	beq	isr_done_update

	;; correct timer interrupt so do the thing
	;; start by restarting the timer 
	lda	SECOND_L
	sta	TIMER2_L	
	lda	SECOND_H
	sta	TIMER2_H	; STARTS the timer and clears the interrupt request

	dec	TIMER_CTR
	lda	TIMER_CTR
	bne	isr_done_update ; counter is not zero

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
	jmp	isr_done_update
	
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
	jmp	isr_done_update
	
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
	jmp	isr_done_update

isr_third_wrap_around:
	inc	NUM_WRAPS
	lda	NUM_WRAPS
	cmp	#$03
	beq	isr_trigger_end_game

	lda	#$00		; NOT end game so reset wraps
	sta	NUM_WRAPS	
	lda	#NUM_NINE
	sta	(SCRN_LSB),y
	jmp	isr_done_update

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
	
isr_done_update:
	pla
	tay			; restore old Y
	pla
	tax			; restore old X
	pla			; restore old A
	
	jmp	OLD_IRQ
