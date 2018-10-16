	processor	6502
	org		$1001

	dc.w	end
	dc.w	1234
	dc.b	$9e, " 4110", 0
end:	dc.w	0

start:	lda	#$01		; letter A
	ldx	#$00
	
loop:	sta	$1e00,X		; ref: page 84
	sta	$1f00,X
	inx			; check for wraparound
	bne	loop

done:	rts
