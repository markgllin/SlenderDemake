S1 	= $900a 			; page 96
S2 	= $900b
S3 	= $900c
S4 	= $900d
VOLUME  = $900e	
	
	processor	6502
	org		$1001

	dc.w	end
	dc.w	1234
	dc.b	$9e, " 4110", 0
end	dc.w	0

start	lda	#$0f
	sta	VOLUME
	lda	#$c8
	sta	S2

	ldx	#$ff
loop3	jsr	delay
	dex	
	bne	loop3
	
	lda	#$00
	sta	S2
	
	rts

;;; --- SUBROUTINES ---
delay	lda 	#$ff
loop1	sbc	#$01
	bne	loop1
	rts
