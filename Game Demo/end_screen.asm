end_screen:
	lda	#00
	sta	VOLUME 

	ldx	#00
end_copy_blank:
	sta	$1ca0,x
	inx	
	cpx	#8
	bne	end_copy_blank

	jsr	prep_splash_screen

	lda	GAME_STATUS
	cmp	#NUM_ZERO
	beq	you_lose

	lda     #<win_message	        ; get low byte of message address to print
	sta	MSG_ADDR_LSB
	lda     #>win_message	        ; get high byte of message address to print
	sta	MSG_ADDR_MSB

	jmp	print_win_lose

you_lose:
	lda     #<lose_message	        ; get low byte of message address to print
	sta	MSG_ADDR_LSB
	lda     #>lose_message	        ; get high byte of message address to print
	sta	MSG_ADDR_MSB
	
print_win_lose:
	jsr	print_message		; common subroutines

	lda	#<score_message
	sta	MSG_ADDR_LSB
	lda	#>lose_message
	sta	MSG_ADDR_MSB
	jsr	print_message

forever:
	jmp	forever

#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                 DATA                   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

win_message:	;; YOU ESCAPED --> 14 bytes
	dc.b	#$1f, #$39-2			; screen position (minus 2)
	;	Y	  O         U
	dc.b	25+#$80, 15+#$80, 21+#$80, #20,
	;       E         S         C         A        P 	 E	  D
	dc.b	5+#$80,  19+#$80, 3+#$80,  1+#$80, 16+#$80, 5+#$80, 4+#$80, END_BYTE
	

lose_message:	;; YOU LOSE --> 11 bytes
	dc.b	#$1f, #$3a-2			; screen position (minus 2)
	;	Y	  O         U
	dc.b	25+#$80, 15+#$80, 21+#$80, #20,
	;       L         O	    S          E
	dc.b	12+#$80, 15+#$80, 19+#$80,  5+#$80, END_BYTE

score_message: 
	dc.b	#$1e, #$00
	;	S	C	O	R	E
	dc.b	19+#$80, 3+#$80, 15+#$80, 18+#$80, 5+#$80, END_BYTE

