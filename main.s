	#include <xc.inc>
	
	psect	code, abs

main:
	org	0x0
	goto	setup

	org	0x100		    ; Main code starts here at address 0x100
table:	
	db	0x00,0x10,0x20,0x30,0x40,0x50,0x60,0x70	;Table loading with 8 bytes
	counter	EQU 0x10 ; Address of counter variable
	num	EQU 8 ;counter
	align	2 ; ensure alignment of subsequent instructions

setup:
	call	SPI_MasterInit ; call master_init function
	
start:	
	movlw	low highword(table) ; address of data in PM
	movwf	TBLPTRU, A ; load upper bits to TBLPTRU
	movlw	high(table) ; address of data in PM
	movwf	TBLPTRH, A ; load high byte to TBLPTRH
	movlw	low(table) ; address of data in PM
	movwf	TBLPTRL, A ; load low byte to TBLPTRL
	movlw	num ; 8 bytes to read
	movwf	counter, A ; our counter register

loop:
	call	SPI_MasterTransmit ; call SPI_MasterTransmit function
	decfsz	counter, F, A ; count down to zero
	bra	loop ; keep going until finished
	goto	start
	
SPI_MasterTransmit:
	tblrd*+ ; move one byte from PM to TABLAT, 					
		; increment TBLPRT
	movf 	TABLAT, W, A ; move read data from TABLAT to W register
	movwf 	SSP2BUF, A 	; write data to output buffer
	call	Wait_Transmit ; call wait_transmit function
	movlw	0x0f                                                                                   ;load delay value
	movwf	0x20, A ;stores value in address 0x20
	call	delay ;call delay
	call	delay
	return
	

SPI_MasterInit:	; Set Clock edge to negative	
	bcf	CKE2	; CKE bit in SSP2STAT
	; MSSP enable; CKP=1; SPI master, clock=Fosc/64 (1MHz)
	movlw 	(SSP2CON1_SSPEN_MASK)|(SSP2CON1_CKP_MASK)|(SSP2CON1_SSPM1_MASK)
	movwf 	SSP2CON1, A	; SDO2 output; SCK2 output
	setf	TRISD, A
	bcf	TRISD, PORTD_SDO2_POSN, A	; SDO2 output	
	bcf	TRISD, PORTD_SCK2_POSN, A	; SCK2 output	
	return 


Wait_Transmit:	; Wait for transmission to complete	
	btfss 	PIR2, 5, A		; check interrupt flag to see if data has been sent                                                                                                                                                                                                                                    
	bra 	Wait_Transmit
	bcf 	PIR2, 5, A		; clear interrupt flag	
	return 
	
delay:
	decfsz	0x20, F, A    ; Decrement until zero
	bra	delay
	return
