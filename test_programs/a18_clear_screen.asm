	processor	6502
	org		$1001

	dc.w	end
	dc.w	1234
	dc.b	$9e, " 4110", 0
end:	dc.w	0

start:	;; starting address of screen: 1e00 (ref page 117)
	;; ending address of screen: 1fff
	
	lda	#$20
	ldx	#$00
loop:	sta	$1e00,X
	sta	$1f00,X
	inx
	bne	loop
done:	jmp	done		; forever loop to prevent "ready"
