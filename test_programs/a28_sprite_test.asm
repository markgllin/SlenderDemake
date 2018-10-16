;;; This program replaces the character A with a smiley face
;;; Example from page 86 was used as reference
	
	processor	6502
	org		$1001

	dc.w	end
	dc.w	1234
	dc.b	$9e, " 4110", 0
end:	dc.w	0

	;; starting destination: 7168  = $1C00
	;; ending destination:   7679  = $1DFF
	;; starting source: 	 32768 = $8000
	;; ending source:	 33279 = $81FF
	
start:	ldx	#0
copy:	lda	$8000,X		; copy the source to the destination above
	sta	$1C00,X		; this copies character rom to ram so we
	lda	$8100,X		; can actually edit it
	sta	$1D00,X

	inx
	bne	copy

	lda	#255
	sta	$9005

	ldx	#0
load:	lda	smile,X		; actually load the smiley face into the place
	sta	$1C08,X		; here A used to be
	inx
	cpx	#8
	bne	load
	
	rts

smile:	dc.b	60,66,165,129,165,153,66,60
