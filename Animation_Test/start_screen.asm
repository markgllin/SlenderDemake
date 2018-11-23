        processor 6502

	INCLUDE "constants.asm"
        INCLUDE "zero_page.asm"

        org     $1001

        dc.w    end
        dc.w    1234
        dc.b    $9e, " 4110", 0
end:
        dc.w    0

start:	jsr 	start_clr

	lda     #255            ; custom character set
        sta     $9005

	;; position the screen
	lda	#12
	sta	SCRN_H	
	lda	#40
	sta	SCRN_V

	lda     #8              ; border black, screen black (ref p. 265)
        sta     SCR_C

	ldx	#00		
	lda	#01
fill_colour_mem:		; fill colour memory with white
	sta	COLOR_MEM,x
	sta	COLOR_MEM+#$ff,x
	inx
	bne	fill_colour_mem

	ldx	#0
copy_logo_256:			; copy first 255 bytes of logo
	lda     logo,X
        sta     CHAR_MEM,X
        inx
        bne     copy_logo_256

	ldx	#0
copy_remaining:			; copy the remaining bytes of the logo
	lda	logo+256,X
	sta	CHAR_MEM+#$100,X
	inx
	cpx	#$68		; remaining 104 bytes
	bne	copy_remaining

	ldx	#00
	lda	#00
copy_blank_loop:		; make sure blank character is where it should be
	sta	CHAR_MEM+#$170,X
	inx	
	cpx	#8
	bne	copy_blank_loop
	
	ldx	#0
copy_letters:
	lda	ALPHABET_ROM,X
	sta	CHAR_MEM+#$178,X
	inx
	cpx	#27
	bne	copy_letters
	
;;;; now that copying is done, print that thing

	;; store screen address MSB for plotting	
	lda	#$1e
	sta	$01

	lda	#0
	sta	$03			; counter for character num
		
	ldy	#0			; counter for columns
	lda	#0
print_logo_row:
	ldx	#0			; counter for rows
	lda	#$5e		
	sta	$00			; LSB of screen memory - controls offset
print_logo_column:
	lda	$03			; print the current character
	sta	($00),y
	inc	$03			; get the next character

	lda	$00			; jump down one row
	clc
	adc	#$16
	sta	$00

	inx				; check if 5 rows have been printed
	cpx	#5
	bne	print_logo_column

	iny				; check if 9 columns have been printed
	cpy	#9
	bne	print_logo_row

	ldx	#0
print_message:
	lda	message,X		; grab index for characters
	sta	$1f35,X
	inx
	cpx	#20
	bne	print_message 


	ldx	#00
	ldy	#00
	lda	#40
	sta	$03
start_input:
	iny
	bne	no_wobble
check_for_wobble:
	dec	$03
	bne	no_wobble
	
	lda	#40
	sta	$03
	jsr	wobble_screen

no_wobble:
	jsr	random
	lda	LFSR
	cmp	#248
	bne	no_glitch
	
	jsr	glitch	

no_glitch:
        lda     SCAN_KEYBOARD
        cmp     #SPACE_KEY
	bne	start_input

	rts

wobble_screen:
	jsr	startFrame
	inx
	cpx	#4
	bmi	move_screen_down
	cpx	#8
	bmi	move_screen_up
	jmp	reset
move_screen_up:
	dec	SCRN_V
	jmp	done_wobble
move_screen_down:
	inc	SCRN_V
	jmp	done_wobble
reset:
	lda	#40
	sta	SCRN_V
	ldx	#0
done_wobble:
	rts

glitch:
	lda	#10
	sta	$04
glitch_loop:
	inc	SCRN_V
	inc	SCRN_H
	dec	$04
	bne	glitch_loop

	lda	#10
	sta	$04
glitch_undo:
	dec	SCRN_V
	dec	SCRN_H
	dec	$04
	bne	glitch_undo
	
	rts

;clears screen
start_clr:
        lda     #46
        ldx     #0
start_clr_loop:
        sta     $1e00,x
        sta     $1f00,x
        inx
        bne     start_clr_loop
        rts

	INCLUDE "common_subroutines.asm"
	
logo:				; total: 45 characters = 360 bytes
	; 1c00
	dc.b 0,0,3,7,14,28,28,30		
	dc.b 30,31,31,31,15,7,1,0
	dc.b 0,0,0,0,0,0,0,0
	dc.b 0,0,0,0,0,0,0,0			; 32 bytes - 4 char (03)
	dc.b 0,0,128,192,192,32,28,3
	dc.b 63,255,255,1,0,0,0,0
	dc.b 0,0,128,224,248,255,255,127
	dc.b 31,7,3,0,0,0,0,0			; 64 bytes - 8 char (07)
	dc.b 0,0,0,0,0,0,0,0
	dc.b 0,0,0,0,0,3,14,248
	dc.b 240,240,224,224,96,64,64,0
	dc.b 0,0,0,0,0,0,192,224		; 96 bytes - 12 char (11)
	dc.b 240,248,248,252,127,63,31,31	
	dc.b 31,15,15,15,15,15,12,12
	dc.b 16,16,48,96,192,128,0,0
	dc.b 48,112,240,112,112,112,112,112	; 128 bytes - 16 char (15)
	dc.b 112,112,112,112,112,112,112,112	
	dc.b 112,112,112,112,120,126,56,56
	dc.b 0,0,0,0,0,0,40,110
	dc.b 42,42,42,42,0,0,0,0		; 160 bytes - 20 char (19)
	dc.b 0,0,0,0,0,0,0,0			
	dc.b 3,7,31,63,32,96,64,124		
	dc.b 76,68,96,96,120,60,56,56
	dc.b 0,0,0,0,0,0,0,227			; 192 bytes - 24 char (23)
	dc.b 162,226,130,227,0,0,0,0		
	dc.b 0,0,0,0,0,0,0,0
	dc.b 2,238,254,254,238,226,226,226	
	dc.b 226,226,226,226,12,12,16,16	; 224 bytes - 28 char (27) 
	dc.b 0,0,0,0,0,0,128,187		
	dc.b 170,186,162,187,2,2,0,0
	dc.b 0,0,96,96,240,240,240,112
	dc.b 24,28,12,14,30,30,23,119		; 256 bytes - 32 char (31)
	; 1d00
	dc.b 227,227,226,242,246,124,16,16      ; 260 bytes - 33 char (32) ---> space
	dc.b 0,0,0,0,0,0,0,187			; 1d10
	dc.b 138,186,170,186,0,0,0,0
	dc.b 0,0,0,0,0,0,0,0			; 1d20
	dc.b 7,14,30,62,100,68,64,252
	dc.b 200,200,224,224,240,124,48,48	; 1d30
	dc.b 0,0,0,0,0,0,32,106
	dc.b 42,42,42,46,0,0,0,0		; 1d40
	dc.b 0,0,0,0,0,0,0,0		
	dc.b 3,39,62,118,178,48,48,48		; 1d50
	dc.b 32,32,32,32,32,96,64,64		; 1d58
	dc.b 0,0,0,0,0,0,0,220			; 1d60
	dc.b 148,156,144,156,0,0,0,0		; 1d68

message:		; "PRESS SPACE TO START"  -> 20 characters
	;   	P         R         E        S         S        
	dc.b	16+#$180, 18+#$180, 5+#$180, 19+#$180, 19+#$180, #46
	;	S         P         A        C        E
	dc.b	19+#$180, 16+#$180, 1+#$180, 3+#$180, 5+#$180, #46
	;   	T         O                S         T         A        R         T
	dc.b	20+#$180, 15+#$180,   #46, 19+#$180, 20+#$180, 1+#$180, 18+#$180, 20+#$180
