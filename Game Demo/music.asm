restart_song:
	lda     #0
        sta     S1_INDEX
        sta     S3_INDEX
        sta     MOD_FLAG

        lda     S1NOTES + 2
        sta     S1_DUR
        lda     S3NOTES + 2
        sta     S3_DUR
	rts

play_notes:
	ldx     S1_INDEX
        lda     S1NOTES,X
        sta     S1              ; load the new note and play it
        ldx     S3_INDEX
        lda     S3NOTES,X
        sta     S3
	rts

;;; --- MUSIC ---
;;; first two bytes are notes, third byte is type / length

S1NOTES:                        ; lowest voice
        dc.b    #206, #207, QURT_NOTE
        dc.b    #206, #207, QURT_NOTE
        dc.b    #200, #200, QURT_NOTE
        dc.b    #200, #200, QURT_NOTE

        dc.b    #192, #195, QURT_NOTE
        dc.b    #192, #195, QURT_NOTE
        dc.b    #200, #200, EIGT_NOTE
        dc.b    #192, #195, EIGT_NOTE
        dc.b    #189, #190, EIGT_NOTE
        dc.b    #206, #207, EIGT_NOTE

        dc.b    #206, #207, QURT_NOTE
        dc.b    #206, #207, QURT_NOTE
        dc.b    #200, #200, QURT_NOTE
        dc.b    #200, #200, QURT_NOTE

        dc.b    #192, #195, QURT_NOTE
        dc.b    #192, #195, QURT_NOTE
        dc.b    #200, #200, EIGT_NOTE
        dc.b    #192, #195, EIGT_NOTE
        dc.b    #189, #190, EIGT_NOTE
        dc.b    #206, #207, EIGT_NOTE

        dc.b    $ff, $ff, $ff


S3NOTES:                        ; highest voice
        dc.b    #234, #235, QURT_NOTE
        dc.b    #234, #235, QURT_NOTE
        dc.b    #233, #233, QURT_NOTE
        dc.b    #233, #233, QURT_NOTE

        dc.b    #234, #234, EIGT_NOTE
        dc.b    #233, #233, EIGT_NOTE
        dc.b    #231, #231, EIGT_NOTE
        dc.b    #239, #239, EIGT_NOTE
        dc.b    #233, #233, QURT_NOTE
        dc.b    #233, #233, QURT_NOTE

        dc.b    #234, #234, QURT_NOTE
        dc.b    #234, #234, QURT_NOTE
        dc.b    #233, #233, QURT_NOTE
        dc.b    #233, #233, QURT_NOTE

        dc.b    #239, #239, EIGT_NOTE
        dc.b    #234, #235, EIGT_NOTE
        dc.b    #233, #233, EIGT_NOTE
        dc.b    #239, #239, EIGT_NOTE
        dc.b    #239, #240, QURT_NOTE
        dc.b    #239, #239, QURT_NOTE


