#include <xc.inc>

extrn	UART_Setup, UART_Transmit_Message  ; external subroutines
extrn	LCD_Setup, LCD_Write_Message
extrn	RTCC_Setup, RTCC_Get_Seconds,  RTCC_Get_Minutes, RTCC_Get_Hours, RTCC_Get_Weekday, RTCC_Get_Day, RTCC_Get_Month, RTCC_Get_Year, RTCC_alarm_get_minutes
extrn	low_nibble_ASCII, high_nibble_ASCII
	
psect	udata_acs   ; reserve data space in access ram
counter:    ds 1    ; reserve one byte for a counter variable
delay_count:ds 1    ; reserve one byte for counter in the delay routine
colons:	    ds 1
    
psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
myArray:    ds 0x80 ; reserve 128 bytes for message data

psect	data    
	; ******* myTable, data in programme memory, and its length *****
myTable:
	db	'H','e','l','l','o',' ','W','o','r','l','d','!',0x0a
					; message, plus carriage return
	myTable_l   EQU	13	; length of data
	align	2
    
psect	code, abs	
rst: 	org 0x0
 	goto	setup
	
int:	org 0x0008  ;high vector
	goto	RTCC_ISR

	; ******* Programme FLASH read Setup Code ***********************
setup:	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	;interrupt
	banksel INTCON
	bsf	INTCON, 7	;enable global interrupt
	bsf	INTCON, 6 ;enable peripheral interrupt
	banksel PIE3
	bsf	PIE3, 0  ;enable RTCC alarm interrupt
	banksel PIR3
	bcf	PIR3, 0  ;clear RTCC interrupt flag
	;
	call	UART_Setup	; setup UART
	call	LCD_Setup	; setup UART
	call	RTCC_Setup	; setup RTCC
	clrf	TRISD, A	; set portD as digital output for seconds display
	clrf	TRISE, A
	goto	loop_clock_read
	
	; ******* Main programme ****************************************
loop_clock_read:
	call	RTCC_Get_Minutes    ; returns seconds value in W
	movwf	PORTD, A	    ; write value out to PORTD 
	call	RTCC_Get_Seconds
	movwf	PORTE, A
	goto	loop_clock_read	    ; goto loop_clock_read
	
	; a delay subroutine if you need one, times around loop in delay_count
delay:	decfsz	delay_count, A	; decrement until zero
	bra	delay
	return

RTCC_ISR: ;RTCC interrupt service routine
	banksel	PIR3
	btfss	PIR3, 0 ;bit test file, skip if alarm interrupt flag is set
	retfie	f ;return from interrupt
	;
	bcf	PIR3, 0 ;clear alarm interrupt flag
	;perform action
	lfsr	0, myArray	; Load FSR0 with address in RAM	
	call	RTCC_Get_Minutes    ; returns minutes value in W
	call	bcd_to_ascii ;convert BCD to ASCII
	movff	high_nibble_ASCII, myArray 
	movff	low_nibble_ASCII, myArray + 1
	
	movlw	0x3A	;ascii code for :
	movwf	colons, A
	movff	colons, myArray + 2
	
	call	RTCC_Get_Seconds
	call	bcd_to_ascii
	movff	high_nibble_ASCII, myArray + 3
	movff	low_nibble_ASCII, myArray + 4
	
	movlw	5
	lfsr	2, myArray
	call	UART_Transmit_Message

	movlw	5
	lfsr	2, myArray
	call	LCD_Write_Message

	retfie  f ;return from interrupt
	end	rst