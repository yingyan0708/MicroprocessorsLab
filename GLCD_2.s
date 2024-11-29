#include <xc.inc>

global	init_LCD, send_data
psect	udata_acs
GLCD_counter:	ds 1	
RS	EQU	2 ;port B is control line
R	EQU	3 ;RW
EN	EQU	4
CS1	EQU	0
CS2	EQU	1
RST	EQU	5
	
psect	glcd_code,class=CODE
init_LCD:
	clrf	TRISD
	clrf	LATD
	clrf	LATB
	bsf	PORTB, RST ;reset
	call	delay
	bsf	PORTB, CS1 ;select left half
	bsf	PORTB, CS2 ;select right half
	call	delay
	movlw	0xB8 ;set to page 0 (x-address)
	call	send_command
	movlw	0x40 ;set to strip 0 in page (y-address)
	call	send_command
	movlw	0xC0 ;start line, start from row 0 (z-address)
	call	send_command
	movlw	0x3F ;display on
	call	send_command
	return

	
send_command: ;RS and R/W are both 0 when sending command
	bcf	PORTB, RS ;clear
	bcf	PORTB, R ; clear RW
	movwf	PORTD ;store command in w, move command to port D where port D is data line
	bsf	PORTB, EN; set Enable pin to 1
	call	delay
	bcf	PORTB, EN
	call	delay
	return

GLCD_Write_Message:	    ; Message stored at FSR2, length stored in W
	movwf   GLCD_counter, A ;length of data
GLCD_Loop_message:
	movf    POSTINC2, W, A
	call    LCD_Send_Byte_D
	decfsz  LCD_counter, A
	bra	LCD_Loop_message
	return
	
send_data: ;when writing/sending data, RS pin is set to 1
	bsf	PORTB, RS
	bcf	PORTB, R
	movwf	PORTD ;place data on port D
	bsf	PORTB, EN; set Enable pin to 1
	call	delay
	bcf	PORTB, EN
	call	delay
	return

delay:
	movlw   0x0F      ; Set the delay counter value (adjust as needed)
	movwf   0x20
delay_loop:
	decfsz  0x20, F
	bra     delay_loop
	return


	


