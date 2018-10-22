;;; ---- ADDRESSES
AUX_C     = $900e	; bits 4-7: auxillary colour
SCR_C     = $900f	; bits 0-2: border color 
                        ; bits 4-7: background color
CHR_C     = $0286	; character color (dec: 646)

COLOR_MEM = $9600	; start of colour memory 
SCRN_MEM1 = $1e00	; start of screen memory
SCRN_MEM2 = $1f00	; middle of screen memory
CHAR_MEM  = $1c00	; start of character memory

SCRN_V    = $9001	; vertical origin of the screen
ROWS	  = $9003	; bits 1-6: number of rows (ref: p 175)
RASTER	  = $9004

NUMBERS_ADDRESS = $1ca0		; where numbers start in custom charset

;; The IRQ vector is the location (ISR) to jump when an interrupt happens
IRQ_L        = $0314		; low byte of IRQ vector 
IRQ_H        = $0315		; high byte of IRQ vector 
OLD_IRQ      = $eabf
	
VIA_CONTROL  = $911b
VIA_FLAGS    = $911d		; reference: page 218
VIA_ENABLE   = $911e

TIMER1_LOC   = $9114		; timer 1 low order counter
TIMER1_HOC   = $9115		; timer 1 high order counter
TIMER1_LOL   = $9116		; timer 1 low order latch
TIMER1_HOL   = $9117		; timer 1 high order latch
	
TIMER2_L     = $9118		; timer 2 low order byte
TIMER2_H     = $9119		; timer 2 high order byte
	
	
;;; ---- ZERO PAGE
SCRN_LSB    = $00	; LSB of screen memory address
SCRN_MSB    = $01	; MSB Of screen memory address	
CLRM_LSB    = $04	; LSB of colour memory address
CLRM_MSB    = $05	; MSB Of colour memory address
	
CURR_SPRITE = $08	; stores the starting character for current sprite
FRAME	    = $09	; frame counter for delays
CURR_CLR    = $0a	; stores the current character colour
TIMER_CTR   = $0b	; timer counter
	
PREV_SCRN_LSB = $10	
PREV_SCRN_MSB = $11
PREV_CLRM_LSB = $14
PREV_CLRM_MSB = $15
	
	
;;; ---- CONSTANTS
CHAR_FORWARD      = #$00	; character facing forward
CHAR_BCKWARD      = #$04	; character facing backward
CHAR_RIGHT        = #$08	; character facing to the right
CHAR_LEFT         = #$0c	; character facing to the left
TREE1             = #$10	
NUM_ZERO	  = #$14	; start of number 0
NUM_NINE	  = #$1d	; start of number 9 
	
SPRITE_CHAR_COLOR = #$09 	; multi-colour white
TREE_CHAR_COLOR   = #$0d	; multi-colour green

;; The timer runs at 1MHz so that means 1,000,000 cycles per second
;; Hence, we need to wait 1,000,000 = $000F 4240 cycles to wait a single second
;; That is, wait $f424 a total of $10 = 16 times.
SECOND_H	  = #$f4	; high byte of $f906
SECOND_L	  = #$24	; low  byte of $f906
NUM_SEC		  = #$11	; 1 MORE THAN how many ^ it takes for a single second
	
	processor	6502
	org		$1001

	dc.w	end
	dc.w	1234
	dc.b	$9e, " 4110", 0
end:	dc.w	0

	;; set up the new IRQ vector for timer 2
timer2_IRQ:
	lda	VIA_CONTROL
	and	#$df	 	; set timer 2 to one-shot-mode
	sta	VIA_CONTROL

	lda	#$a0 		; enable timer 2
	sta 	VIA_ENABLE
	
	sei			; disable interrupts

	lda	#<isr_update_timer	; get low byte of ISR address
				; reference for this notation: page 204
	sta	IRQ_L
	lda	#>isr_update_timer	; get high byte of ISR address
	sta	IRQ_H

	cli			; enable interrupts again
	
start:
	lda	#14	; border blue, screen black (ref p. 265)
	sta 	SCR_C
	lda	#112	; yellow = first byte 7 (ref p. 264)
			; 112 = 0111 0000 where 111 = 7
	sta	AUX_C
	lda	#01	; white characters
	sta	CHR_C

	lda	#$20
	ldx	#$00	
clear_loop:			; clear the screen
	sta	SCRN_MEM1,X
	sta	SCRN_MEM2,X
	inx
	bne	clear_loop

	;; copy the numbers from memory
	;; a.k.a copy starting from $8000 + ($30 * 8) = $8000 + $180 = $8180
	;; Copy all 10 characters: 10 * 8 = 80 = $50 bytes to copy
	ldx	#$0
copy:	lda	$8180,X			; copy the source to the destination
	sta	NUMBERS_ADDRESS,X	; end of sprites
	inx
	cpx	#$50		; copy characters 0-9
	bne	copy
	
	lda	#255		; custom character set
	sta	$9005
	
init_numbers:
	lda	#$00
	sta	SCRN_LSB
	sta	CLRM_LSB
	lda	#$1e
	sta	SCRN_MSB
	lda	#$96
	sta	CLRM_MSB

	ldy	#$0	
init_loop:	
	lda	#NUM_ZERO 		; number 0
	sta	(SCRN_LSB),y		; position
	lda	#$01			; font color = white
	sta	(CLRM_LSB),y
	iny
	cpy	#$04
	bne	init_loop

	ldy	#$01
	lda	#NUM_ZERO + 3		; number 3
	sta	(SCRN_LSB),y
	
	lda	#NUM_SEC
	sta	TIMER_CTR
start_timer:
	lda	SECOND_L
	sta	TIMER2_L
	lda	SECOND_H
	sta	TIMER2_H	; STARTS the timer
	
	rts

isr_update_timer:
	pha			; save old A
	txa
	pha			; save old X
	tya
	pha			; save old Y

	;; check that the interrupt is happening from timer 2
	lda	VIA_FLAGS
	and	#$20		; check TIMER2 bit ($20 = 0010 0000)
	beq	isr_done_update	; TIMER2 bit is not set so different interrupt

	;; correct timer interrupt so do the thing
	;; start by restarting the timer 
	lda	SECOND_L
	sta	TIMER2_L	
	lda	SECOND_H
	sta	TIMER2_H	; STARTS the timer and clears the interrupt request

	dec	TIMER_CTR
	lda	TIMER_CTR
	bne	isr_done_update ; counter is not zero

	;; a second has passed
	lda	#NUM_SEC	; reload counter
	sta	TIMER_CTR

isr_first_digit:		; check the seconds digit
	ldy	#$03
	lda	(SCRN_LSB),y
	cmp	#NUM_ZERO
	beq	isr_first_wrap_around

	sec
	sbc	#$01	
	sta	(SCRN_LSB),y
	jmp	isr_done_update
	
isr_first_wrap_around:
	lda	#NUM_NINE
	sta	(SCRN_LSB),y

	ldy	#$02		; check second digit
	lda	(SCRN_LSB),y
	cmp	#NUM_ZERO
	beq	isr_second_wrap_around

	sec
	sbc	#$01
	sta	(SCRN_LSB),y
	jmp	isr_done_update
	
isr_second_wrap_around:	
	lda	#NUM_NINE
	sta	(SCRN_LSB),y
	
	ldy	#$01		; check third digit
	lda	(SCRN_LSB),y
	cmp	#NUM_ZERO
	beq	isr_third_wrap_around

	sec
	sbc	#$01
	sta	(SCRN_LSB),y
	jmp	isr_done_update

isr_third_wrap_around:
	lda	#NUM_NINE
	sta	(SCRN_LSB),y
	
isr_done_update:
	pla
	tay			; restore old Y
	pla
	tax			; restore old X
	pla			; restore old A
	
	jmp	OLD_IRQ
	
