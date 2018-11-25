end_screen:
	lda	#00
	sta	VOLUME 

	jsr	prep_splash_screen

	lda	#$1f
	sta	SCRN_OFFSET_MSB	

	lda	GAME_STATUS
	cmp	#NUM_ZERO
	beq	you_lose

	lda     #<win_message	        ; get low byte of message address to print
	sta	MSG_ADDR_LSB
	lda     #>win_message	        ; get high byte of message address to print
	sta	MSG_ADDR_MSB
	lda	#$39
	sta	SCRN_OFFSET_LSB
	jsr	print_message
	
	jmp	forever

you_lose:
	lda     #<lose_message	        ; get low byte of message address to print
	sta	MSG_ADDR_LSB
	lda     #>lose_message	        ; get high byte of message address to print
	sta	MSG_ADDR_MSB
	lda	#$3a
	sta	SCRN_OFFSET_LSB
	jsr	print_message

forever:
	jmp	forever

win_message:	;; YOU ESCAPED --> 11 bytes
	;	Y	  O         U
	dc.b	25+#$180, 15+#$180, 21+#$180, #46,
	;       E         S         C         A        P 	 E	  D
	dc.b	5+#$180,  19+#$180, 3+#$180,  1+#$180, 16+#$180, 5+#$180, 4+#$180, END_BYTE
	

lose_message:	;; YOU LOSE --> 8 bytes
	;	Y	  O         U
	dc.b	25+#$180, 15+#$180, 21+#$180, #46,
	;       L         O	    S          E
	dc.b	12+#$180, 15+#$180, 19+#$180,  5+#$180, END_BYTE
	
