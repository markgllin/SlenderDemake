AUX_C = $900e	; bits 4-7: auxillary colour
SCR_C = $900f	; bits 0-2: border color 
                ; bits 4-7: background color
CHR_C = $0286	; character color (dec: 646)

COLOR_MEM = $9600

	processor	6502
	org		$1001

	dc.w	end
	dc.w	1234
	dc.b	$9e, " 4110", 0
end:	dc.w	0

start:
	lda	#12	; border purple, screen black (ref p. 265)
	sta 	SCR_C
	lda	#144	; light orange (ref p. 264)
	sta	AUX_C
	;; lda	#09	; white characters, multi-color mode
	;; sta	CHR_C	; actually, nevermind, this does nothing LOL

	lda	#$20
	ldx	#$00	
clear_loop:			; clear the screen
	sta	$1e00,X
	sta	$1f00,X
	inx
	bne	clear_loop

	lda	#255		; custom character set
	sta	$9005

	;; now, load the sprite into memory
 	ldx	#0
load:	lda	sprite,X
 	sta	$1C00,X	
 	inx
 	cpx	#96
 	bne	load
	
	;; store screen address for calculations later  
	lda 	#$00              ; load LSB
	sta 	$0
	lda 	#$1e              ; load MSB
	sta 	$1

	ldx	#0
	jsr	drawChar
	
	rts
	
drawChar:
	ldy	#0      ; draw 1st char
	jsr	draw
	inx      	; draw 2nd char
	ldy	#22
	jsr	draw
	inx 	 	; draw 3rd char
	ldy	#1
	jsr	draw
	inx   	   	; draw 4th char
	ldy 	#23
	jsr 	draw
	
	rts

; needs character to draw in x
; needs offset in y
draw:
	txa
	sta 	($0),y
	lda	#$09		; high res white
	sta	COLOR_MEM,y
	rts

sprite:
	;;  sprite facing forward
	BYTE	21,85,118,89,89,30,90,85
	BYTE	7,31,31,31,127,85,4,4
	BYTE	84,84,164,152,152,172,164,85
	BYTE	208,100,100,220,253,85,16,16

	;; sprite facing backward
	BYTE	21,85,117,85,85,85,85,21
	BYTE	7,31,31,127,127,85,4,4
	BYTE	84,85,85,85,85,85,85,84
	BYTE	208,244,244,253,253,85,16,16

	;; sprite to the side
	BYTE	21,85,117,94,86,87,22,85
	BYTE	7,31,31,31,127,85,16,16
	BYTE	84,84,164,100,105,164,164,80
	BYTE	208,244,217,217,244,84,16,16
