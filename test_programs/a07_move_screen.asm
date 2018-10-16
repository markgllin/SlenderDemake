SCREEN_ORG_H = $9000
SCREEN_ORG_V = $9001
POS_H	     = $fb
POS_V	     = $fc	
	
	processor	6502
	org		$1001

	dc.w	end
	dc.w	1234
	dc.b	$9e, " 4110", 0
end	dc.w	0

start	lda	SCREEN_ORG_H
	and 	#$80		; 1000 0000
	sta	POS_H
	lda	SCREEN_ORG_V
	sta	POS_V

move	lda	POS_H
	adc	#$05
	sta	SCREEN_ORG_H
	rts
