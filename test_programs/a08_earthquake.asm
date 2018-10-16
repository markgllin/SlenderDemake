SCREEN_ORG_H = $9000
SCREEN_ORG_V = $9001	
	
	processor	6502
	org		$1001

	dc.w	end
	dc.w	1234
	dc.b	$9e, " 4110", 0
end	dc.w	0

init	ldx	#$0C
	ldy	#$26
	stx	SCREEN_ORG_H
	sty	SCREEN_ORG_V

jiggle	jsr 	up
	jsr	left
	jsr	down
	jsr	right

	jmp	init

	rts
	

;;; --- SUBROUTINES ---
frame	lda	$9004
	cmp	#$00
	bne	frame
	rts
	
delay	lda	#$99
loop	sbc	#$02
	bne	loop
	jsr	frame
	rts
	
up	lda	SCREEN_ORG_V
	sbc	#$03
	sta	SCREEN_ORG_V
	jsr	delay
	rts

down	lda	SCREEN_ORG_V
	adc	#$03
	sta	SCREEN_ORG_V
	jsr	delay
	rts

left	lda	SCREEN_ORG_H	
	sbc	#$02
	sta	SCREEN_ORG_H
	jsr	delay
	rts

right	lda	SCREEN_ORG_H	
	adc	#$02
	sta	SCREEN_ORG_H
	jsr	delay
	rts
