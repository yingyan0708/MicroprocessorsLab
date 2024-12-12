#include <xc.inc>

extrn	UART_Setup, UART_Transmit_Message  ; external subroutines
	
psect	udata_acs   ; reserve data space in access ram
counter:    ds 1    ; reserve one byte for a counter variable
delay_count:ds 1    ; reserve one byte for counter in the delay routine
first_digit:ds 1
second_digit: ds 1
third_digit: ds 1
forth_digit: ds 1

psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
myArray:    ds 0x80 ; reserve 128 bytes for message data

psect	data    
	; ******* myTable, data in programme memory, and its length *****
myTable:
	db	'H','e','l','l','o',' ','W','o','r','l','d','!',0x0a
					; message, plus carriage return
	myTable_l   EQU	5	; length of data
	align	2
    
psect	code, abs	
rst: 	org 0x0
 	goto	setup

	; ******* Programme FLASH read Setup Code ***********************
setup:	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	call	UART_Setup	; setup UART
	goto	start
	
	; ******* Main programme ****************************************
start: 	lfsr	0, myArray	; Load FSR0 with address in RAM	
	movlw	0x30
	movwf	first_digit, A
	movff   first_digit, POSTINC0
	movlw	0x31
	movwf	second_digit, A
	movff	second_digit, POSTINC0
	movlw   0x0D              ; ASCII for Carriage Return (CR)
	movwf   POSTINC0          ; Add CR to myArray
	movlw   0x0A              ; ASCII for Line Feed (LF)
	movwf   POSTINC0          ; Add LF to myArray
	movlw	0x32
	movwf	third_digit, A
	movff	third_digit, POSTINC0	
	movlw	myTable_l	; output message to UART
	lfsr	2, myArray
	call	UART_Transmit_Message

	goto	$		; goto current line in code

	; a delay subroutine if you need one, times around loop in delay_count
delay:	decfsz	delay_count, A	; decrement until zero
	bra	delay
	return

	end	rst