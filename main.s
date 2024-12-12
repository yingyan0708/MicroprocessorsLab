#include <xc.inc>

extrn	UART_Setup, UART_Transmit_Message  ; external subroutines
extrn	LCD_Setup, LCD_Write_Message, first_line, second_line
extrn	RTCC_Setup, RTCC_Get_Seconds,  RTCC_Get_Minutes, RTCC_Get_Hours, RTCC_Get_Weekday, RTCC_Get_Day, RTCC_Get_Month, RTCC_Get_Year, RTCC_alarm_get_minutes
extrn	low_nibble_ASCII, high_nibble_ASCII, bcd_to_ascii
extrn	ADC_Setup, ADC_Read, multiplication, mul24and8, RES3, RES0, RES1, RES2,  ARG2H, ARG2L, NRES0, NRES1, NRES2, NRES3	   ; external ADC subroutines
;extrn	data_logger, temp_data
;extrn	new_data_logger
;extrn	_start, PWMOn, Delay1Second, PWMOff 
extrn	keypad_setup, keypad_read, alarm_mask, buzzer_threshold_L, buzzer_threshold_H
extrn	init_LCD, send_data, send_command, CS1, CS2, colon, compare_number
global	high_hour
    
psect	udata_acs   ; reserve data space in access ram
counter:    ds 1    ; reserve one byte for a counter variable
delay_count:ds 1    ; reserve one byte for counter in the delay routine
colons:	    ds 1
dash:	    ds 1
spaces:	    ds 1
dot:	    ds 1
R1:	    ds 1
R2:	    ds 1
R3:	    ds 1
count:	    ds 1   
page_counter:	ds  1
page_pointer:	ds 1
page_counter_CS2:   ds	1
subtract:	ds 1
subtract_CS2:	ds 1
high_hour:	ds 1
low_hour:	ds 1
high_minute:	ds 1
low_minute:	ds 1
high_second:	ds 1
low_second:	ds 1
    
    
psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
myArray:    ds 0x80 ; reserve 128 bytes for message data

psect	udata_bank5 ; reserve data anywhere in RAM (here at 0x400)
dataArray:    ds 0x100 ; reserve 128 bytes for message data

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
	bsf	INTCON, 7, A	;enable global interrupt
	bsf	INTCON, 6, A ;enable peripheral interrupt
	banksel PIE3
	bsf	PIE3, 0, A  ;enable RTCC alarm interrupt
	banksel PIR3
	bcf	PIR3, 0, A  ;clear RTCC interrupt flag
	;
	call	UART_Setup	; setup UART
	;call	LCD_Setup	; setup UART
	call	RTCC_Setup	; setup RTCC
	call	ADC_Setup
	call	keypad_setup
	;clrf	TRISD, A	; set portD as digital output for seconds display
	clrf	TRISJ, A
	;initialise GLCD
	call	init_LCD
	bcf	PORTB, CS2 ;
	nop
	bsf	PORTB, CS1;set CS2 active
	nop
	call	clear_display
	bcf	PORTB, CS1
	nop
	bsf	PORTB, CS2;set CS1 active
	nop
	call	clear_display
	movlw	0xB8
	movwf	page_pointer, A
	

	clrf	TRISH            ; Configure PORTH as output for buzzer
        clrf	PORTH           ; Clear PORTH (all pins LOW)
	goto	loop
	
	; ******* Main programme ****************************************
loop:	
	;call	init_LCD
	call	ADC_Read
	;call	keypad_read
	movlw	0x00         ; Load high byte of 0x12C (0x012C)
	;movwf	buzzer_
	;movf	buzzer_threshold_H, W, A
        cpfslt	ADRESH       ; Compare ADRESH with 0x01, skip if ADRESH < 0x01
	call	check_ADRESL
	;movlw	0x00
	;cpfseq	high_hour, A
	;call	GLCD_print_high_hour
	goto	loop

GLCD_print_high_hour:
	bcf	PORTB, CS2 ;
	nop
	bsf	PORTB, CS1;set CS2 active
	nop
	call	page_setup
	movf    page_counter, W, A ; 
	call	send_command

	movlw	0x40 ; set to strip 0 in page (y-address)
	call	send_command
	movf	high_hour, W, A
	call	compare_number
	goto	GLCD_print_low_hour
	
GLCD_print_low_hour:
	movf	low_hour, W, A
	call	compare_number
	goto	GLCD_print_colon_1
	
GLCD_print_colon_1:
	call	colon
	goto	GLCD_print_high_minute

GLCD_print_high_minute:
	movf	high_minute, W, A
	call	compare_number
	goto	GLCD_print_low_minute
	
GLCD_print_low_minute:
	movf	low_minute, W, A
	call	compare_number
	goto	GLCD_print_colon_2

GLCD_print_colon_2:
	call	colon
	goto	GLCD_print_high_second
	
GLCD_print_high_second:
	movf	high_second, W, A
	call	compare_number
	goto	GLCD_print_low_second

GLCD_print_low_second:
	movf	low_second, W, A
	call	compare_number
	return

page_setup:
	movlw	0xBF
	cpfseq	page_pointer,A
	bra     not_last_page
	movlw	0xB8
	movwf	page_pointer, A
	return
	    
not_last_page:; Increment the counter
	incf    page_pointer, F
	return
	

    
	
    

check_ADRESL:
	movlw	0xFA
	;movf	buzzer_threshold_L, W, A
	cpfslt	ADRESL  ; Compare ADRESL with 0x2C, skip if ADRESH < 0x2C
	call	Buzzer
	return
	
	
loop_clock_read:
	;call	first_line
	;read year
	call	RTCC_Get_Year
	call	bcd_to_ascii ;convert BCD to ASCII
	movff	high_nibble_ASCII, myArray + 1
	movf	high_nibble_ASCII, W
	;call	compare_number
	movff	low_nibble_ASCII, myArray + 2
	movf	high_nibble_ASCII, W
	
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
	
	;movlw	9
	;lfsr	2, myArray
	;call	LCD_Write_Message
	
	;read hour
	;call	second_line
	call	RTCC_Get_Hours    ; returns seconds value in W
	call	bcd_to_ascii ;convert BCD to ASCII
	movff	high_nibble_ASCII, myArray 
	movff	low_nibble_ASCII, myArray + 1
	movff	high_nibble_ASCII, high_hour
	movff	low_nibble_ASCII, low_hour
	
	;lfsr	0, dataArray
	;movff	high_nibble_ASCII, POSTINC0
	;movff	low_nibble_ASCII, POSTINC0
	
	movlw	0x3A	;ascii code for :
	movwf	colons, A
	movff	colons, myArray + 2
	
	call	RTCC_Get_Minutes    ; returns seconds value in W
	call	bcd_to_ascii ;convert BCD to ASCII
	movff	high_nibble_ASCII, myArray + 3
	movff	low_nibble_ASCII, myArray + 4
	movff	high_nibble_ASCII, high_minute
	movff	low_nibble_ASCII, low_minute

	movff	colons, myArray + 5
	
	call	RTCC_Get_Seconds
	call	bcd_to_ascii
	movff	high_nibble_ASCII, myArray + 6
	movff	low_nibble_ASCII, myArray + 7
	movff	high_nibble_ASCII, high_second
	movff	low_nibble_ASCII, low_second
	
	movlw	0x20
	movwf	spaces, A
	movff	spaces, myArray + 8
	;just to print alarm value
	;call	RTCC_alarm_get_minutes
	;call	bcd_to_ascii
	;movff	high_nibble_ASCII, myArray + 9
	;movff	low_nibble_ASCII, myArray + 10
	
	;movwf	PORTD, A	    ; write value out to PORTD 
	;movwf	PORTE, A
	return
	
	; a delay subroutine if you need one, times around loop in delay_count
delay:	decfsz	delay_count, A	; decrement until zero
	bra	delay
	return

RTCC_ISR: ;RTCC interrupt service routine
	banksel	PIR3
	btfss	PIR3, 0, A ;bit test file, skip if alarm interrupt flag is set
	retfie	f ;return from interrupt
	;
	bcf	PIR3, 0, A ;clear alarm interrupt flag
	;perform action
	incf	LATJ, F, A	; increment PORTD
	call	loop_clock_read
	call	ADC_Read
	call	GLCD_print_high_hour
	call    multiplication
	call	mul24and8
	;movlw	0x0043		; scaling factor for temperature conversion
	;call	multiplication
	;call	mul24and8
	movlw	0x30		; ASCII code conversion
	addwf	RES3, F, A
	movff	RES3, myArray + 9
	
	call	mul24and8
	movlw	0x30
	addwf	RES3, F, A
	movff	RES3, myArray + 10
	call	mul24and8
	movlw	0x2E	;ascii code for .
	movwf	dot, A
	movff	dot, myArray + 11
	movlw	0x30
	addwf	RES3, F, A
	movff	RES3, myArray + 12
	
	;movlw	13
	;lfsr	2, myArray
	;call	LCD_Write_Message
	
	retfie  f ;return from interrupt
	
Buzzer:
	bsf	LATH, 0           ; Set RB0 HIGH (turn ON buzzer)
        call	DELAY            ; Wait for a period
        bcf	LATH, 0           ; Set RB0 LOW (turn OFF buzzer)
	
DELAY:
	MOVLW 0x3D            ; Outermost loop count (~61 iterations)
	MOVWF R3              ; Store in R3
DELAY_OUTER3:
	MOVLW 0xFF            ; Outer loop count (256 iterations)
	MOVWF R1              ; Store in R1
DELAY_OUTER:
	MOVLW 0xFF            ; Inner loop count (256 iterations)
	MOVWF R2              ; Store in R2
DELAY_INNER:
	NOP                   ; 1 cycle
	NOP                   ; Add more NOPs for fine-tuning
	DECFSZ R2, F          ; Decrement R2, skip if 0 (1 or 2 cycles)
	GOTO DELAY_INNER      ; Repeat inner loop (2 cycles)
	DECFSZ R1, F          ; Decrement R1, skip if 0 (1 or 2 cycles)
	GOTO DELAY_OUTER      ; Repeat outer loop (2 cycles)
	DECFSZ R3, F          ; Decrement R3, skip if 0 (1 or 2 cycles)
	GOTO DELAY_OUTER3     ; Repeat outermost loop (2 cycles)
	RETURN                ; Return to main program

clear_display:
	; Clear pages and reset cursor for each page (0xB8 to 0xBF)
	movlw	0xB8 ; Set to page 0 (x-address)
	call	send_command
	movlw	0x40 ; Set to strip 0 in page (y-address)
	call	send_command
	call	clear_page

	movlw	0xB9 ; Set to page 1 (x-address)
	call	send_command
	movlw	0x40 ; Set to strip 0 in page (y-address)
	call	send_command
	call	clear_page

	movlw	0xBA ; Set to page 2 (x-address)
	call	send_command
	movlw	0x40 ; Set to strip 0 in page (y-address)
	call	send_command
	call	clear_page

	movlw	0xBB ; Set to page 3 (x-address)
	call	send_command
	movlw	0x40 ; Set to strip 0 in page (y-address)
	call	send_command
	call	clear_page

	movlw	0xBC ; Set to page 4 (x-address)
	call	send_command
	movlw	0x40 ; Set to strip 0 in page (y-address)
	call	send_command
	call	clear_page

	movlw	0xBD ; Set to page 5 (x-address)
	call	send_command
	movlw	0x40 ; Set to strip 0 in page (y-address)
	call	send_command
	call	clear_page

	movlw	0xBE ; Set to page 6 (x-address)
	call	send_command
	movlw	0x40 ; Set to strip 0 in page (y-address)
	call	send_command
	call	clear_page

	movlw	0xBF ; Set to page 7 (x-address)
	call	send_command
	movlw	0x40 ; Set to strip 0 in page (y-address)
	call	send_command
	call	clear_page
	
	return

; Routine to clear a page (sets column address to 0x40 and sends 0x00 to clear)
clear_page:
	movlw	0x40 ; Set column address to the beginning of the page
	movwf	count
clear_loop:
	call	clear
	decfsz	count
	bra	clear_loop
	return

; Routine to send a clear command (send 0x00 data to clear the display)
clear:
	movlw	0x00
	call	send_data
	return	

	

    end	rst 