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
	sta 	S3_INDEX
	sta	FLAG
	sta	MOD_FLAG

init:	ldx	#$02
	lda	S3NOTES,X
	sta	S3_DUR

	lda	#$0f
	sta	VOLUME

	
frame:	jsr	play_notes
	jsr	modulate

	lda	RASTER
	bne	frame
	
	jsr	next_note
	
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
	dec	MOD_FLAG	; change to zero mod=
	dec	S3_INDEX
	jmp	done_mod
zero_mod:			; currently pointing at first  "mod" note
	inc	MOD_FLAG	; change to one mod
	inc	S3_INDEX
done_mod:
	rts

;;; **** play_notes
;;; 	 This subroutine loads all the notes into their registers
play_notes:
	ldx	S3_INDEX
	lda	S3NOTES,X
	cmp	#$ff
	beq	done_song
	sta	S3
	rts
	
;;; **** next_note
;;;      This subroutine grabs the next note for each voice
add_mod:
	inx
	rts

next_note:	
	dec	S3_DUR
	lda	S3_DUR
	bne	done_notes
change_S1:
	;; move the S1 pointer to the next note
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
	
S3NOTES:			; highest voice
	dc.b	#239, #239, QURT_NOTE
	dc.b	#239, #240, QURT_NOTE
	dc.b	#239, #239, QURT_NOTE
	dc.b	#240, #240, QURT_NOTE
	dc.b	$ff,  $ff,  $ff
	
