#include <xc.inc>

extrn	UART_Setup, UART_Transmit_Message  ; external subroutines
extrn	LCD_Setup, LCD_Write_Message, first_line, second_line
extrn	RTCC_Setup, RTCC_Get_Seconds,  RTCC_Get_Minutes, RTCC_Get_Hours, RTCC_Get_Weekday, RTCC_Get_Day, RTCC_Get_Month, RTCC_Get_Year, RTCC_alarm_get_minutes
extrn	low_nibble_ASCII, high_nibble_ASCII, bcd_to_ascii
	
psect	udata_acs   ; reserve data space in access ram
counter:    ds 1    ; reserve one byte for a counter variable
delay_count:ds 1    ; reserve one byte for counter in the delay routine
colons:	    ds 1
dash:	    ds 1
spaces:	    ds 1
    
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
	call	first_line
	;read year
	call	RTCC_Get_Year
	call	bcd_to_ascii ;convert BCD to ASCII
	movff	high_nibble_ASCII, myArray + 1
	movff	low_nibble_ASCII, myArray + 2
	
	;dash
	movlw	0x2D
	movwf	dash, A
	movff	dash, myArray + 3
	
	;read month
	call	RTCC_Get_Month
	call	bcd_to_ascii ;convert BCD to ASCII
	movff	high_nibble_ASCII, myArray + 4
	movff	low_nibble_ASCII, myArray + 5
	
	movff	dash, myArray + 6
	
	;read day
	call	RTCC_Get_Day
	call	bcd_to_ascii ;convert BCD to ASCII
	movff	high_nibble_ASCII, myArray + 7
	movff	low_nibble_ASCII, myArray + 8
	
	movlw	9
	lfsr	2, myArray
	call	LCD_Write_Message
	
	;read hour
	call	second_line
	call	RTCC_Get_Hours    ; returns seconds value in W
	call	bcd_to_ascii ;convert BCD to ASCII
	movff	high_nibble_ASCII, myArray + 1
	movff	low_nibble_ASCII, myArray + 2
	
	movlw	0x3A	;ascii code for :
	movwf	colons, A
	movff	colons, myArray + 3
	
	call	RTCC_Get_Minutes    ; returns seconds value in W
	call	bcd_to_ascii ;convert BCD to ASCII
	movff	high_nibble_ASCII, myArray + 4
	movff	low_nibble_ASCII, myArray + 5

	movff	colons, myArray + 6
	
	call	RTCC_Get_Seconds
	call	bcd_to_ascii
	movff	high_nibble_ASCII, myArray + 7
	movff	low_nibble_ASCII, myArray + 8
	;just to print alarm value
	call	RTCC_alarm_get_minutes
	call	bcd_to_ascii
	movff	high_nibble_ASCII, myArray + 9
	movff	low_nibble_ASCII, myArray + 10

	movlw	11
	lfsr	2, myArray
	call	LCD_Write_Message
	;movwf	PORTD, A	    ; write value out to PORTD 
	;movwf	PORTE, A
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
	incf	LATD, F, A	; increment PORTD
	retfie  f ;return from interrupt
	end	rst