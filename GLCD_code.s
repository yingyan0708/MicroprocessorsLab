#include <xc.inc>

global init_LCD, send_data, send_command,CS1,CS2

psect	udata_acs
LCD_cnt_l:	ds 1   ; reserve 1 byte for variable LCD_cnt_l
LCD_cnt_h:	ds 1   ; reserve 1 byte for variable LCD_cnt_h

RS  EQU	2 ;port B is control line
R   EQU 3 ;RW
EN  EQU	4
CS1 EQU	0
CS2 EQU	1
RST EQU	5

psect	glcd,class=CODE
   
init_LCD:
	clrf	PORTB, A
	clrf	PORTD, A
	clrf	LATD, A ;clear PORTD output latch (data lines)
	clrf	LATB, A ;clear PORTB output latch (control lines)
	clrf	TRISD, A ;Set all PORTD pins as outputs (data lines)
	clrf	TRISB, A

	bcf	PORTB, RST
	nop ;delay
	bsf	PORTB, RST
	nop ;delay

	movlw	0x3F ; Function Set: 8-bit, 128x64 resolution, normal display
	call	send_command

	movlw	0xB8 ;set to page 0 (x-address)
	call	send_command

	movlw	0x40 ;set to strip 0 in page (y-address)
	call	send_command

	movlw	0xC0 ;start line, start from row 0 (z-address)
	call	send_command

	bcf	PORTB, CS2
	nop
	bsf	PORTB, CS1;ft half active
	nop
	
	return

send_command: ;RS and R/W are both 0 when sending command
	bcf	PORTB, RS, A ;clear RS
	nop
	nop
	bcf	PORTB, R, A ;clear RW
	nop
	nop
	movwf	PORTD ;store command in w, move command to port D where port D is data line
	bsf	PORTB, EN ;enable pin to 1
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	bcf	PORTB, EN
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	return

send_data: ;when writing/sending data, RS pin is set to 1
	bsf	PORTB, RS
	nop
	bcf	PORTB, R
	nop
	movwf	PORTD ;place data on port D
	bsf	PORTB, EN
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	bcf	PORTB, EN
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	movlw	10
	call	LCD_delay_x4us
	return

LCD_delay_x4us:		    ; delay given in chunks of 4 microsecond in W
	movwf	LCD_cnt_l, A	; now need to multiply by 16
	swapf   LCD_cnt_l, F, A	; swap nibbles
	movlw	0x0f	    
	andwf	LCD_cnt_l, W, A ; move low nibble to W
	movwf	LCD_cnt_h, A	; then to LCD_cnt_h
	movlw	0xf0	    
	andwf	LCD_cnt_l, F, A ; keep high nibble in LCD_cnt_l
	call	LCD_delay
	return

LCD_delay:			; delay routine	4 instruction loop == 250ns	    
	movlw 	0x00		; W=0
lcdlp1:	decf 	LCD_cnt_l, F, A	; no carry when 0x00 -> 0xff
	subwfb 	LCD_cnt_h, F, A	; no carry when 0x00 -> 0xff
	bc 	lcdlp1		; carry, then loop again
	return			; carry reset so return

end