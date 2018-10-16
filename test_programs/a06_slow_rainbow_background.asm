FRAME  = $fb
COLOUR = $fc
	

	processor	6502
	org		$1001

	dc.w	end
	dc.w	1234
	dc.b	$9e, " 4110", 0
end	dc.w	0

black	lda	#$08		; wrap around back to black
	sta	COLOUR
start	sta	$900f		; change screen colour
	lda	#$00
	sta	FRAME
frame	lda	$9004		; raster beam line number
	cmp	#$0		; top of the screen
	bne 	frame
	inc	FRAME		; increase frame counter
	lda	FRAME
	cmp	#$99		; add max delay
	bne	frame
	
next	lda	COLOUR
	adc	#$10
	cmp	#$f8
	bmi	black
	sta	COLOUR
	jmp	start
	rts
