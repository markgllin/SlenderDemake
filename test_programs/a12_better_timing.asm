RASTER  = $9004
S1 	= $900a 			; page 96
S2 	= $900b
S3 	= $900c
S4 	= $900d
VOLUME  = $900e		
	
TIME_H	= $a0
TIME_M	= $a1
TIME_L	= $a2	
	
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
	lda	S3NOTES,X
	sta	S3

	pha			; save accumulator
	txa
	pha			; save x
	tya
	pha			; save y
	jsr	wait1
	pla
	tay			; restore y
	pla
	tax			; restore x
	pla			; restor accumulator
	
	inx
	cpx	#$07
	bne	play

	lda	#$00
	sta	S1
	sta	VOLUME
	
	rts

;;; --- SUBROUTINES ---

;; wait 1 second = 60 jiffies
wait1	lda	#$c4		; 5,184,000 jiffies = 24:00:00 = 0x4F1A00
				; 5,183,940 jiffies = 23:59:58 = 0x4F19C4
	ldx	#$19
	ldy	#$4f
	jsr	$ffd7		; KERNEL: SETTIM
loop	lda	TIME_H		; check for wrap around
	bne	loop
	rts			; 60 jiffies elapsed

;;; --- MUSIC ---
	
	;; first byte is note, second byte is length
S1NOTES dc.b	$e7		; high E for 4 counts
	dc.b	$e0		; step down to C 
	dc.b	$e7		; high E
	dc.b	$e3		; step down to D
	dc.b	$e7		; repeat above
	dc.b	$e0		
	dc.b	$e7		
	dc.b	$e3				

S3NOTES	dc.b	$ef, $ea, $e7, $e5, $ea, $f0, $ef, $ea
