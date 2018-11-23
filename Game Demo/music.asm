
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


