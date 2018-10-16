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
MOD_FLAG = $f7
	
WHOL_NOTE = #$80
HALF_NOTE = #$40
QURT_NOTE = #$20
SIXT_NOTE = #$10
	
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

	lda	#$01
	sta	MOD_FLAG

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
	jsr	modulate

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
;;; **** modulate
;;; 	 This subroutine modulates the current note being played (for each voice)
modulate:
	lda	MOD_FLAG
	beq	zero_mod
one_mod:			; point at first "mod" note
	dec	MOD_FLAG
	inc	S1_INDEX
	inc	S2_INDEX
	inc	S3_INDEX
	jmp	done_mod
zero_mod:			; point at second "mod" note
	inc	MOD_FLAG
	dec 	S1_INDEX
	dec	S2_INDEX
	dec	S3_INDEX
done_mod:	
	rts
	
;;; **** next_note
;;;      This subroutine grabs the next note for each voice
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

	;; grab next note and load it to S1 (if not the end)
	lda	S1NOTES,X
	cmp	#$ff
	beq	set_flag
	sta	S1

	;; get duration for new note
	lda	S1_INDEX
	adc	MOD_FLAG 	; if MOD_FLAG = 1 (i.e. pointing at first note)
				; must add 1 to reach duration 
	tax
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

	;; grab and play new note
	lda	S2NOTES,X
	sta	S2

	;; grab new note duration
	lda	S2_INDEX
	adc	MOD_FLAG
	tax
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

	;; grab and play new note
	lda	S3NOTES,X
	sta	S3

	;; grab new note duration
	lda	S3_INDEX
	adc	MOD_FLAG
	tax
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
	
	;; first byte is note, second byte is type
S1NOTES:
	dc.b	#192, #195, WHOL_NOTE
	dc.b	#200, #200, WHOL_NOTE	
	dc.b	#206, #207, WHOL_NOTE		
	dc.b	#208, #209, WHOL_NOTE
	dc.b	#214, #214, WHOL_NOTE
	dc.b	#218, #219, WHOL_NOTE
	dc.b	#222, #223, WHOL_NOTE
	dc.b	#224, #224, WHOL_NOTE
	
	dc.b	$ff, $ff

S2NOTES:
	dc.b	#192, #195, WHOL_NOTE
	dc.b	#200, #200, WHOL_NOTE	
	dc.b	#206, #207, WHOL_NOTE		
	dc.b	#208, #209, WHOL_NOTE
	dc.b	#214, #214, WHOL_NOTE
	dc.b	#218, #219, WHOL_NOTE
	dc.b	#222, #223, WHOL_NOTE
	dc.b	#224, #224, WHOL_NOTE
	
S3NOTES:
	dc.b	#192, #195, WHOL_NOTE
	dc.b	#200, #200, WHOL_NOTE	
	dc.b	#206, #207, WHOL_NOTE		
	dc.b	#208, #209, WHOL_NOTE
	dc.b	#214, #214, WHOL_NOTE
	dc.b	#218, #219, WHOL_NOTE
	dc.b	#222, #223, WHOL_NOTE
	dc.b	#224, #224, WHOL_NOTE
