;;; *** ADDRESSES ***
	
;; The IRQ vector is the location (ISR) to jump when an interrupt happens
IRQ_L        = $0314		; low byte of IRQ vector 
IRQ_H        = $0315		; high byte of IRQ vector 
;; I originally tried reading the values from the locations above and
;; storing them to jump to later, but for some reason I was grabbing
;; $ea96 instead of the correct address $eabf that was stored there
;; when I checked my other programs that didn't use interrupts. 
;; So, I just hardcoded jumping to the correct ISR instead.
;; This fixed a LOT of the problems I Was having with the program crashing. 
OLD_IRQ      = $eabf
	
VIA_CONTROL  = $911b
VIA_FLAGS    = $911d		; reference: page 218
VIA_ENABLE   = $911e
TIMER2_L     = $9118		; timer 2 low order byte
TIMER2_H     = $9119		; timer 2 high order byte

S1 	     = $900a 		; reference: page 96
S2 	     = $900b
S3 	     = $900c
S4 	     = $900d
VOLUME       = $900e



;;; *** CONSTANTS ***
WHOL_NOTE = #32
HALF_NOTE = #16
QURT_NOTE = #8
EIGT_NOTE = #4	
SIXT_NOTE = #2

SIXT_L = #$fe		; length of sixteenth note - low byte
SIXT_H = #$ff		; length of sixteenth note - high byte	
	
;;; *** ZERO PAGE ***
S1_INDEX  = $f0
S1_DUR	  = $f1
S3_INDEX  = $f2
S3_DUR    = $f3	
MOD_FLAG  = $f4
	
	processor	6502
	org		$1001

	dc.w	end
	dc.w	1234
	dc.b	$9e, " 4110", 0
end:	dc.w	0

	;; set up the new IRQ vector
music_IRQ:
	lda	VIA_CONTROL
	and	#$df	 	; set timer 2 to one-shot-mode
	sta	VIA_CONTROL

	lda	#$a0 		; enable timer 2
	sta 	VIA_ENABLE
	
	sei			; disable interrupts

	lda	#<isr_next_note	; get low byte of ISR address
				; reference for this notation: page 204
	sta	IRQ_L
	lda	#>isr_next_note	; get high byte of ISR address
	sta	IRQ_H

	cli			; enable interrupts again

start:	
	lda	#0
	sta	S1_INDEX
	sta	MOD_FLAG
	lda	S1NOTES + 2
	sta	S1_DUR
	lda	#$0f
	sta	VOLUME

	;; store the length of a single sixteenth note in timer 2 
	lda	SIXT_L
	sta	TIMER2_L
	lda	SIXT_H
	sta	TIMER2_H	; STARTS the timer

	rts
	
;;; **** ISR : next_note
;;;      This ISR grabs the next note for each voice when timer 2 runs out
;;;  	 If the timer hasn't run out yet, modulate the note instead
isr_next_note:
	pha			; save old A
	txa
	pha			; save old X
	
	lda	VIA_FLAGS
	and	#$20		; check TIMER2 bit ($20 = 0010 0000)
	bne	new_sixteenth	; TIMER2 bit is set so a sixteenth note has passed

	jmp	modulate	; else, continue on to modulation 
	
new_sixteenth:	
	dec	S1_DUR		; single sixteenth note has passed
	bne	done_notes	; if not zero, check next voice
change_S1:	
	;; move the S1 pointer to the next note
	ldx	S1_INDEX
	inx
	inx
	inx
	lda	S1NOTES,X
	cmp	#$ff
	beq 	done_song
	stx	S1_INDEX

	;; get duration for new note
	lda	MOD_FLAG
	beq	add_mod
	inx
	lda	S1NOTES,X
	sta	S1_DUR
	
done_notes:			; we have checked all the voices
	;;  restart the timer
	lda	SIXT_L
	sta	TIMER2_L	
	lda	SIXT_H
	sta	TIMER2_H	; STARTS the timer and clears the interrupt request
	
	jmp	modulate	; modulate the notes

done_song:
	;; restart the song from the beginning
	lda	#0
	sta	S1_INDEX
	sta	MOD_FLAG
	lda	S1NOTES + 2
	sta	S1_DUR

	;;  restart the timer
	lda	SIXT_L
	sta	TIMER2_L	
	lda	SIXT_H
	sta	TIMER2_H	; STARTS the timer and clears the interrupt request

	jmp 	done_mod
modulate:			; modulate the notes
	lda	MOD_FLAG
	beq	zero_mod
one_mod:			; currently pointing at second "mod" note
	dec	MOD_FLAG	; change to zero mod
	dec	S1_INDEX	; point at first "mod" note
	jmp	done_mod
zero_mod:			; currently pointing at first  "mod" note
	inc	MOD_FLAG	; change to one mod
	inc	S1_INDEX	; point at second "mod" note
done_mod:
	ldx	S1_INDEX
	lda	S1NOTES,X
	sta	S1		; load the new note and play it
	
	pla
	tax			; restore old X
	pla			; restore old A
	jmp	OLD_IRQ		; continue on to old IRQ
	rti

add_mod:
	inx
	rts

;;; --- MUSIC ---
;;; first two bytes are notes, third byte is type / length
	
S1NOTES:			; lowest voice
	dc.b	#206, #207, QURT_NOTE
	dc.b	#206, #207, QURT_NOTE
	dc.b	#200, #200, QURT_NOTE
	dc.b	#200, #200, QURT_NOTE
	
	dc.b	#192, #195, QURT_NOTE
	dc.b	#192, #195, QURT_NOTE
	dc.b	#200, #200, EIGT_NOTE
	dc.b	#192, #195, EIGT_NOTE
	dc.b	#189, #190, EIGT_NOTE
	dc.b	#206, #207, EIGT_NOTE

	dc.b	#206, #207, QURT_NOTE
	dc.b	#206, #207, QURT_NOTE
	dc.b	#200, #200, QURT_NOTE
	dc.b	#200, #200, QURT_NOTE
	
	dc.b	#192, #195, QURT_NOTE
	dc.b	#192, #195, QURT_NOTE
	dc.b	#200, #200, EIGT_NOTE
	dc.b	#192, #195, EIGT_NOTE
	dc.b	#189, #190, EIGT_NOTE
	dc.b	#206, #207, EIGT_NOTE

	dc.b	$ff, $ff, $ff

	
S3NOTES:			; highest voice
	dc.b	#234, #235, QURT_NOTE
	dc.b	#234, #235, QURT_NOTE
	dc.b	#233, #233, QURT_NOTE
	dc.b	#233, #233, QURT_NOTE

	dc.b	#234, #234, EIGT_NOTE
	dc.b	#233, #233, EIGT_NOTE
	dc.b	#231, #231, EIGT_NOTE
	dc.b	#239, #239, EIGT_NOTE
	dc.b	#233, #233, QURT_NOTE
	dc.b	#233, #233, QURT_NOTE
	
	dc.b	#234, #234, QURT_NOTE
	dc.b	#234, #234, QURT_NOTE
	dc.b	#233, #233, QURT_NOTE
	dc.b	#233, #233, QURT_NOTE

	dc.b	#239, #239, EIGT_NOTE
	dc.b	#234, #235, EIGT_NOTE
	dc.b	#233, #233, EIGT_NOTE
	dc.b	#239, #239, EIGT_NOTE
	dc.b	#239, #240, QURT_NOTE
	dc.b	#239, #239, QURT_NOTE
