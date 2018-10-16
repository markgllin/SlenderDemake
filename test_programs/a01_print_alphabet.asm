	processor	6502
	org		$1001

	dc.w	end
	dc.w	1234
	dc.b	$9e, " 4110", 0
end	dc.w	0

start	ldx	#$41
	
loop	txa
	jsr 	$ffd2
	inx
	cpx	#$5b 		; has z been reached
	bne	loop
done	rts
