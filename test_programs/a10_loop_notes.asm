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

	ldx	#$00
play	lda	S1NOTES,X	
	sta	S1

	ldy	#$ff
pause	jsr	delay
	jsr	delay
	dey
	bne	pause
	
	inx
	cpx	#$08
	bne	play

	lda	#$00
	sta	S1
	sta	VOLUME
	
	rts

;;; --- SUBROUTINES ---
delay	lda 	#$ff
loop	sbc	#$01
	bne	loop
	rts

	;; first byte is note, second byte is length
S1NOTES dc.b	$e7		; high E for 4 counts
	dc.b	$e0		; step down to C 
	dc.b	$e7		; high E
	dc.b	$e3		; step down to D
	dc.b	$e7		; repeat above
	dc.b	$e0		
	dc.b	$e7		
	dc.b	$e3		
	dc.b	$e0		

	
