	#include <xc.inc>
	
	psect	code, abs

main:
	org	0x0
	goto	start

	org	0x100		    ; Main code starts here at address 0x100
table:	
	db	0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07	;Table loading with 8 bytes
	counter	EQU 0x10 ; Address of counter variable
	num	EQU 8 ;counter
	align	2 ; ensure alignment of subsequent instructions

start:	
	clrf	TRISC, A ;clears PORTC
	movlw	low highword(table) ; address of data in PM
	movwf	TBLPTRU, A ; load upper bits to TBLPTRU
	movlw	high(table) ; address of data in PM
	movwf	TBLPTRH, A ; load high byte to TBLPTRH
	movlw	low(table) ; address of data in PM
	movwf	TBLPTRL, A ; load low byte to TBLPTRL
	movlw	num ; 8 bytes to read
	movwf	counter, A ; our counter register
	
loop:
	tblrd*+ ; move one byte from PM to TABLAT, 					
		; increment TBLPRT
	movff 	TABLAT, PORTC ; move read data from TABLAT to
			    ; PORTC, increment PORTC	
	movlw	0x0f ;all bits in
	movwf	0x20, A ;stores value in address 0x20
	call	delay
	decfsz	counter, A ; count down to zero
	bra	loop ; keep going until finished
	goto	start
	
delay:
	decfsz	0x20,A    ; Decrement until zero
	bra	delay
	return
