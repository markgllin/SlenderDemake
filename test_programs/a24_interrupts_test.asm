;; The IRQ vector is the location (ISR) to jump when an interrupt happens
IRQ_L = $0314			; low byte of IRQ vector 
IRQ_H = $0315			; high byte of IRQ vector 
	
	processor	6502
	org		$1001

	dc.w	end
	dc.w	1234
	dc.b	$9e, " 4110", 0
end:	dc.w	0

	;; start by setting up the new IRQ vector
start:	
	sei			; disable interrupts
	lda	#<isr		; get low byte of ISR address
				; reference for this notation: page 204
	sta	IRQ_L
	lda	#>isr		; get high byte of ISR address
	sta	IRQ_H
	cli			; enable interrupts again
	rts

isr:	inc	$900f
	rti
	
