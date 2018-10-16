	processor	6502
	org		$1001

	dc.w	end
	dc.w	1234
	dc.b	$9e, " 4110", 0
end	dc.w	0

start	ldx	#24		; reference: appendix B
raster	lda	$9004		; raster beam line number
	cmp	#$0		; top of the screen
	bne 	raster
	txa
	sta	$900f		; change screen colour
	inx
	cpx	#31
	beq	start
	jmp	raster
	rts
