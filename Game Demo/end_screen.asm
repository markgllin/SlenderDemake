end_screen:
	lda	#00
	sta	VOLUME 

	jsr	prep_splash_screen

	lda	GAME_STATUS
	cmp	#NUM_ZERO
	beq	you_lose

	lda     #<win_message	        ; get low byte of message address to print
	sta	MSG_ADDR_LSB
	lda     #>win_message	        ; get high byte of message address to print
	sta	MSG_ADDR_MSB

	jmp	print

you_lose:
	lda     #<lose_message	        ; get low byte of message address to print
	sta	MSG_ADDR_LSB
	lda     #>lose_message	        ; get high byte of message address to print
	sta	MSG_ADDR_MSB
	
print:
	jsr	print_message		; common subroutines

forever:
	jmp	forever

#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                 DATA                   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

win_message:	;; YOU ESCAPED --> 14 bytes
	dc.b	#$1f, #$39-2			; screen position (minus 2)
	;	Y	  O         U
	dc.b	25+#$180, 15+#$180, 21+#$180, #46,
	;       E         S         C         A        P 	 E	  D
	dc.b	5+#$180,  19+#$180, 3+#$180,  1+#$180, 16+#$180, 5+#$180, 4+#$180, END_BYTE
	

lose_message:	;; YOU LOSE --> 11 bytes
	dc.b	#$1f, #$3a-2			; screen position (minus 2)
	;	Y	  O         U
	dc.b	25+#$180, 15+#$180, 21+#$180, #46,
	;       L         O	    S          E
	dc.b	12+#$180, 15+#$180, 19+#$180,  5+#$180, END_BYTE
