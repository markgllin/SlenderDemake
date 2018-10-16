	processor	6502
	org		$1001

	dc.w	end
	dc.w	1234
	dc.b	$9e, " 4110", 0
end	dc.w	0

start	lda	#26		; reference: appendix B
	sta	$900f
	rts
