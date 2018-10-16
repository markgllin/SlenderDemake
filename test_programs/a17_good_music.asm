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
MOD_FLAG = $f6
FLAG 	 = $f7
	
WHOL_NOTE = #160
HALF_NOTE = #80
QURT_NOTE = #40
EIGT_NOTE = #20	
SIXT_NOTE = #10
	
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
	sta	MOD_FLAG

init:	ldx	#$02
	lda	S1NOTES,X
	sta	S1_DUR
	lda	S2NOTES,X
	sta	S2_DUR
	lda	S3NOTES,X
	sta	S3_DUR

	lda	#$0a
	sta	VOLUME

	jsr	play_notes
frame:	jsr	wait_for_frame

	jsr	modulate
	jsr	next_note
	jsr	play_notes
	
	lda	FLAG
	cmp	#$ff
	beq	done_song

	jsr	modulate
	jsr	play_notes

	jmp	frame

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
	
;;; **** modulate
;;; 	 This subroutine modulates the current note being played (for each voice)
modulate:
	lda	MOD_FLAG
	beq	zero_mod
one_mod:			; currently pointing at second "mod" note
	dec	MOD_FLAG	; change to zero mod
	dec	S1_INDEX
	dec	S2_INDEX
	dec	S3_INDEX
	jmp	done_mod
zero_mod:			; currently pointing at first  "mod" note
	inc	MOD_FLAG	; change to one mod
	inc	S1_INDEX
	inc	S2_INDEX
	inc	S3_INDEX
done_mod:
	rts

;;; **** play_notes
;;; 	 This subroutine loads all the notes into their registers
play_notes:
	ldx	S1_INDEX
	lda	S1NOTES,X
	sta 	S1

	ldx	S2_INDEX
	lda	S2NOTES,X
	sta	S2
	
	ldx	S3_INDEX
	lda	S3NOTES,X
	sta	S3
	rts
	
;;; **** next_note
;;;      This subroutine grabs the next note for each voice
add_mod:
	inx
	rts

next_note:	
	dec	S1_DUR
	lda	S1_DUR
	bne	check_S2
change_S1:
	;; move the S1 pointer to the next note
	ldx	S1_INDEX
	inx
	inx
	inx
	stx	S1_INDEX

	;; check if the end
	lda	S1NOTES,X
	cmp	#$ff
	beq	set_flag

	;; get duration for new note
	lda	MOD_FLAG
	beq	add_mod
	inx
	
	lda	S1NOTES,X
	sta	S1_DUR
	
check_S2:
	dec	S2_DUR
	lda	S2_DUR
	bne	check_S3
change_S2:
	;; move the S2 pointer to the next note
	ldx	S2_INDEX
	inx
	inx
	inx
	stx	S2_INDEX

	;; get duration for new note
	lda	MOD_FLAG
	beq	add_mod
	inx
	
	lda	S2NOTES,X
	sta	S2_DUR

check_S3:
	dec	S3_DUR
	lda	S3_DUR
	bne	done_notes
change_S3:
	;; move the S3 pointer to the next note
	ldx	S3_INDEX
	inx
	inx
	inx
	stx	S3_INDEX

	;; get duration for new note
	lda	MOD_FLAG
	beq	add_mod
	inx

	lda	S3NOTES,X
	sta	S3_DUR
	
	jmp	done_notes

set_flag:
	lda	#$ff
	sta	FLAG
done_notes:	
	rts

;;; --- MUSIC ---
;;; first byte is note, second byte is type

S1NOTES:			; lowest voice
	dc.b	#206, #207, QURT_NOTE
	dc.b	#206, #207, QURT_NOTE
	dc.b	#200, #200, QURT_NOTE
	dc.b	#200, #200, QURT_NOTE
	
	dc.b	#192, #195, QURT_NOTE
	dc.b	#192, #195, QURT_NOTE
	dc.b	#200, #200, EIGT_NOTE
	dc.b	#192, #195, EIGT_NOTE
	dc.b	#189, #190, EIGT_NOTE
	dc.b	#206, #207, EIGT_NOTE

	dc.b	#206, #207, QURT_NOTE
	dc.b	#206, #207, QURT_NOTE
	dc.b	#200, #200, QURT_NOTE
	dc.b	#200, #200, QURT_NOTE
	
	dc.b	#192, #195, QURT_NOTE
	dc.b	#192, #195, QURT_NOTE
	dc.b	#200, #200, EIGT_NOTE
	dc.b	#192, #195, EIGT_NOTE
	dc.b	#189, #190, EIGT_NOTE
	dc.b	#206, #207, EIGT_NOTE

	dc.b	$ff, $ff, $ff

S2NOTES:			; middle voice
	dc.b	#000, #000, WHOL_NOTE
	dc.b	#000, #000, WHOL_NOTE
	dc.b	#000, #000, WHOL_NOTE
	dc.b	#000, #000, WHOL_NOTE	
	
S3NOTES:			; highest voice
	dc.b	#234, #235, QURT_NOTE
	dc.b	#234, #235, QURT_NOTE
	dc.b	#233, #233, QURT_NOTE
	dc.b	#233, #233, QURT_NOTE

	dc.b	#234, #234, EIGT_NOTE
	dc.b	#233, #233, EIGT_NOTE
	dc.b	#231, #231, EIGT_NOTE
	dc.b	#239, #239, EIGT_NOTE
	dc.b	#233, #233, QURT_NOTE
	dc.b	#233, #233, QURT_NOTE
	
	dc.b	#234, #234, QURT_NOTE
	dc.b	#234, #234, QURT_NOTE
	dc.b	#233, #233, QURT_NOTE
	dc.b	#233, #233, QURT_NOTE

	dc.b	#239, #239, EIGT_NOTE
	dc.b	#234, #235, EIGT_NOTE
	dc.b	#233, #233, EIGT_NOTE
	dc.b	#239, #239, EIGT_NOTE
	dc.b	#239, #240, QURT_NOTE
	dc.b	#239, #239, QURT_NOTE
	
