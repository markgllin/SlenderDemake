        processor 6502

        org     $1001

        dc.w    end
        dc.w    1234
        dc.b    $9e, " 4110", 0
end:
        dc.w    0

start:	jsr 	clr

	lda     #255            ; custom character set
        sta     $9005

	lda     #8              ; border black, screen black (ref p. 265)
        sta     $900f

	ldx	#00
	lda	#01
fill_colour_mem:
	sta	$9600,x
	sta	$9700,x
	inx
	bne	fill_colour_mem

	ldx	#0
copy_logo_256:			; copy first 255 bytes of logo
	lda     logo,X
        sta     $1c00,X
        inx
        bne     copy_logo_256

	ldx	#0
copy_remaining:			; copy the remaining bytes of the logo
	lda	logo+256,X
	sta	$1d00,X
	inx
	cpx	#$68		; remaining 104 bytes
	bne	copy_remaining
	
	ldx	#00
	lda	#00
copy_blank_loop:		; make sure blank character is where it should be
	sta	$1d70,X
	inx	
	cpx	#8
	bne	copy_blank_loop

	;; store screen address for plotting	
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

	
forever:
	jmp	forever

;clears screen
clr:            subroutine
        lda     #46
        ldx     #0
.clrloop:
        sta     $1e00,x
        sta     $1f00,x
        inx
        bne     .clrloop
        rts
	
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
