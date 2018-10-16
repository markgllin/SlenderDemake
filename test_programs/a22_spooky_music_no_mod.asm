RASTER  = $9004
S1 	= $900a 			; page 96
S2 	= $900b
S3 	= $900c
S4 	= $900d
VOLUME  = $900e		
	
TIME_H	= $a0
TIME_M	= $a1
TIME_L	= $a2	

S1_INDEX = $f0
S1_DUR   = $f1
S2_INDEX = $f2
S2_DUR   = $f3
S3_INDEX = $f4
S3_DUR   = $f5
FLAG	 = $f6
	
	
WHOL_NOTE = #160
HALF_NOTE = #80
QURT_NOTE = #40	
EIGT_NOTE = #20
	
	processor	6502
	org		$1001

	dc.w	end
	dc.w	1234
	dc.b	$9e, " 4110", 0
end:	dc.w	0

start:	lda	#$00
	sta	S1_INDEX
	sta	S2_INDEX
	sta 	S3_INDEX
	sta	FLAG

init:	lda	S1NOTES
	sta	S1
	lda	S2NOTES
	sta	S2
	lda	S3NOTES
	sta	S3

	ldx	#$01
	lda	S1NOTES,X
	sta	S1_DUR
	lda	S2NOTES,X
	sta	S2_DUR
	lda	S3NOTES,X
	sta	S3_DUR

	lda	#$0f
	sta	VOLUME
	
frame:	jsr	wait_for_frame
	jsr	next_note

	lda	FLAG
	cmp	#$ff
	bne 	frame

done_song:
	lda	#$00
	sta	S1
	sta	S2
	sta	S3
	sta	VOLUME
	
	rts

;;; --- SUBROUTINES ---
	
	
;;; **** wait_for_frame
;;;      This subroutine waits for the next frame before returning
wait_for_frame:	
	lda	RASTER
	cmp	#$00
	bne	wait_for_frame
	rts

;;; **** next_note
;;;      This subroutine grabs the next note for each voice
next_note:	
	dec	S1_DUR
	lda	S1_DUR
	bne	keep_S1
change_S1:
	ldx	S1_INDEX
	inx
	inx
	stx	S1_INDEX

	lda	S1NOTES,X
	cmp	#$ff
	beq	set_flag
	sta	S1

	inx
	lda	S1NOTES,X
	sta	S1_DUR
	jmp	check_S2
keep_S1:	
	sta	S1_DUR
	
check_S2:
	dec	S2_DUR
	lda	S2_DUR
	bne	keep_S2
change_S2:
	ldx	S2_INDEX
	inx
	inx
	stx	S2_INDEX

	lda	S2NOTES,X
	sta	S2

	inx
	lda	S2NOTES,X
	sta	S2_DUR
	jmp	check_S3
keep_S2:
	sta	S2_DUR

check_S3:
	dec	S3_DUR
	lda	S3_DUR
	bne	keep_S3
change_S3:
	ldx	S3_INDEX
	inx
	inx
	stx	S3_INDEX

	lda	S3NOTES,X
	sta	S3

	inx
	lda	S3NOTES,X
	sta	S3_DUR
	jmp	done_notes
keep_S3:
	sta	S3_DUR
	jmp	done_notes
set_flag:
	lda	#$ff
	sta	FLAG
done_notes:	
	rts

;;; --- MUSIC ---
	
;;; --- MUSIC ---
;;; first byte is note, second byte is type

S1NOTES:			; lowest voice
	dc.b	#206, QURT_NOTE
	dc.b	#206, QURT_NOTE
	dc.b	#200, QURT_NOTE
	dc.b	#200, QURT_NOTE
	dc.b	#192, QURT_NOTE
	dc.b	#192, QURT_NOTE
	dc.b	#200, EIGT_NOTE
	dc.b	#192, EIGT_NOTE
	dc.b	#189, EIGT_NOTE
	dc.b	#206, EIGT_NOTE

	dc.b	#206, QURT_NOTE
	dc.b	#206, QURT_NOTE
	dc.b	#200, QURT_NOTE
	dc.b	#200, QURT_NOTE
	
	dc.b	#192, QURT_NOTE
	dc.b	#192, QURT_NOTE
	dc.b	#200, EIGT_NOTE
	dc.b	#192, EIGT_NOTE
	dc.b	#189, EIGT_NOTE
	dc.b	#206, EIGT_NOTE

	dc.b	$ff, $ff, $ff

S2NOTES:			; middle voice
	dc.b	#000, WHOL_NOTE ; silent for now
	dc.b	#000, WHOL_NOTE
	dc.b	#000, WHOL_NOTE
	dc.b	#000, WHOL_NOTE	
	
S3NOTES:			; highest voice
	dc.b	#234, QURT_NOTE
	dc.b	#234, QURT_NOTE
	dc.b	#233, QURT_NOTE
	dc.b	#233, QURT_NOTE

	dc.b	#234, EIGT_NOTE
	dc.b	#233, EIGT_NOTE
	dc.b	#231, EIGT_NOTE
	dc.b	#239, EIGT_NOTE
	dc.b	#233, QURT_NOTE
	dc.b	#233, QURT_NOTE
	
	dc.b	#234, QURT_NOTE
	dc.b	#234, QURT_NOTE
	dc.b	#233, QURT_NOTE
	dc.b	#233, QURT_NOTE

	dc.b	#239, EIGT_NOTE
	dc.b	#234, EIGT_NOTE
	dc.b	#233, EIGT_NOTE
	dc.b	#239, EIGT_NOTE
	dc.b	#239, QURT_NOTE
	dc.b	#239, QURT_NOTE
	
