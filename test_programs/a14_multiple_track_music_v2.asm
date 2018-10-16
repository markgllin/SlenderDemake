RASTER  = $9004
S1 	= $900a 			; page 96
S2 	= $900b
S3 	= $900c
S4 	= $900d
VOLUME  = $900e		
	
TIME_H	= $a0
TIME_M	= $a1
TIME_L	= $a2	

SONG_S1 = $fb
SONG_S2 = $fc
SONG_S3 = $fd		
	
	processor	6502
	org		$1001

	dc.w	end
	dc.w	1234
	dc.b	$9e, " 4110", 0
end	dc.w	0

start	ldx	#$00
	lda	#$0f
	sta	VOLUME

play	lda	S1NOTES,X	
	sta	S1

	lda	S2NOTES,X
	sta	S2
	
	lda	S3NOTES,X
	cmp	#$ea
	bne	no_ocilate
ocilate lda	S3
	cmp	#$ea
	beq	change
	lda	#$ea
	jmp	no_ocilate
change	lda	#$eb
	
no_ocilate
	sta	S3
	
eighth	pha			; save accumulator
	txa
	pha			; save x
	tya
	pha			; save y
	jsr	eighth_note
	pla
	tay			; restore y
	pla
	tax			; restore x
	pla			; restore accumulator

	inx
	
	lda	S1NOTES,X
	cmp	#$ff
	bne	play

	lda	#$00
	sta	S1
	sta	VOLUME
	
	rts

;;; --- SUBROUTINES ---

;;; wait 1/2th of a second = 30 jiffies
eighth_note
	lda	#$e2		; 5,184,000 jiffies = 24:00:00 = 0x4F1A00
				; 5,183,970 jiffies = 0x4F19F6
	ldx	#$19
	ldy	#$4f
	jsr	$ffd7		; KERNEL: SETTIM
loop16	lda	TIME_H		; check for wrap around
	bne	loop16
	rts			; 10 jiffies elapsed	
	
;;; wait 1 second = 60 jiffies
wait1	lda	#$c4		; 5,184,000 jiffies = 24:00:00 = 0x4F1A00
				; 5,183,940 jiffies = 23:59:58 = 0x4F19C4
	ldx	#$19
	ldy	#$4f
	jsr	$ffd7		; KERNEL: SETTIM
loop	lda	TIME_H		; check for wrap around
	bne	loop
	rts			; 60 jiffies elapsed

;;; --- MUSIC ---
	
	;; a byte is a single quarter note
S1NOTES dc.b	$00, $00, $00, $00, $e1, $e1, $e1, $e1	
	dc.b	$00, $00, $00, $00, $e3, $e3, $e3, $e3	
	dc.b	$e7, $e7, $e7, $e7, $e1, $e1, $e1, $e1	
	dc.b	$e7, $e7, $e7, $e7, $e3, $e3, $e3, $e3	
	dc.b	$ff, $ff

S2NOTES dc.b	$e0, $ea, $ef, $e9, $e0, $ea, $ef, $e9
	dc.b	$00, $ef, $ea, $e7, $00, $e3, $e8, $ee
	dc.b	$e0, $ea, $ef, $e9, $e0, $ea, $ef, $e9
	dc.b	$00, $ef, $ea, $e7, $00, $e3, $e8, $ee
	
;;; C - G - B - F#
S3NOTES	dc.b	$e0, $ea, $ef, $e9, $e0, $ea, $ef, $e9
	dc.b	$00, $ef, $ea, $e7, $00, $e3, $e8, $ee
	dc.b	$e0, $ea, $ef, $e9, $e0, $ea, $ef, $e9
	dc.b	$00, $ef, $ea, $e7, $00, $e3, $e8, $ee
