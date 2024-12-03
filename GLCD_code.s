#include <xc.inc>

global init_LCD, send_data, send_command,CS1,CS2

psect	udata_acs
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
	bcf	PORTB, R, A ;clear RW
	nop
	movwf	PORTD ;store command in w, move command to port D where port D is data line
	bsf	PORTB, EN ;enable pin to 1
	nop
	nop
	bcf	PORTB, EN
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
	bcf	PORTB, EN
	nop
	nop
	return

end


	