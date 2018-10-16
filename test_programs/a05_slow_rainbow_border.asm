FRAME = $fb	

	processor	6502
	org		$1001

	dc.w	end
	dc.w	1234
	dc.b	$9e, " 4110", 0
end	dc.w	0

black	ldx	#24		; wrap around back to black
start	lda	#$00
	sta	FRAME	
frame	lda	$9004		; raster beam line number
	cmp	#$0		; top of the screen
	bne 	frame
	inc	FRAME		; increase frame counter
	lda	FRAME
	cmp	#$99		; add max delay
	bne	frame
	
change	txa
	sta	$900f		; change screen colour
	inx
	cpx	#32
	beq	black
	jmp	start
	rts
