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
extrn	init_LCD, send_data, send_command, CS1, CS2, colon, compare_number, dot, degrees, letterC, spaces_bitmap,  letterT, letterC, lettert, letterE,letterM,letterP,letterR,letterU,letterA,letterI
global	high_hour, page_counter, page_pointer, DELAY
    
psect	udata_acs   ; reserve data space in access ram
counter:    ds 1    ; reserve one byte for a counter variable
delay_count:ds 1    ; reserve one byte for counter in the delay routine
colons:	    ds 1
dash:	    ds 1
spaces:	    ds 1
dot_ASCII:	    ds 1
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
temp_reading_1:	    ds 1
temp_reading_2:	    ds 1
temp_reading_3:	    ds 1
    
    
psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
myArray:    ds 0x80 ; reserve 128 bytes for message data

psect	udata_bank5 ; reserve data anywhere in RAM (here at 0x400)
dataArray:    ds 0x100 ; reserve 128 bytes for message data

psect	data    
	; ******* myTable, data in programme memory, and its length *****
myTable:
	db	'H','e','l','l','o',' ','W','o','r','l','d','!',0x0a
					; message, plus carriage return
	myTable_l   EQU	26	; length of data
	align	2
    
psect	code, abs	
rst: 	org 0x0
 	goto	setup
	
int:	org 0x0008  ;high vector
	goto	RTCC_ISR

	; ******* Programme FLASH read Setup Code ***********************
setup:	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	call	keypad_setup
	call	keypad_read

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
	
	;clrf	TRISD, A	; set portD as digital output for seconds display
	clrf	TRISJ, A
	;initialise GLCD
	call	init_LCD
	bcf	PORTB, CS1
	nop
	bsf	PORTB, CS2;set CS1 active
	nop
	call	clear_display
	movlw	0xB8 ; set to page 0 (x-address)
	call	send_command
	movlw	0x40 ; set to strip 0 in page (y-address)
	call	send_command
	call	spaces_bitmap
	call	spaces_bitmap
	call	letterT
	call	letterI
	call	letterM
	call	letterE
	call	spaces_bitmap
	call	spaces_bitmap
	
	;set CS2 active, display temp
	bcf	PORTB, CS2 ;
	nop
	bsf	PORTB, CS1;set CS2 active
	nop
	call	clear_display
	movlw	0xB8 ; set to page 0 (x-address)
	call	send_command
	movlw	0x40 ; set to strip 0 in page (y-address)
	call	send_command
	call	spaces_bitmap
	call	spaces_bitmap
	call	letterT
	call	letterE
	call	letterM
	call	letterP
	call	spaces_bitmap
	call	spaces_bitmap

	movlw	0xB8
	movwf	page_pointer, A
	clrf	TRISH            ; Configure PORTH as output for buzzer
        clrf	PORTH           ; Clear PORTH (all pins LOW)
	goto	loop
	
	; ******* Main programme ****************************************
loop:		
	;call	init_LCD
	call	ADC_Read
	;movlw	0x00         ; Load high byte of 0x12C (0x012C)
	movf	buzzer_threshold_H, W, A
        cpfslt	ADRESH       ; Compare ADRESH with 0x01, skip if ADRESH < 0x01
	call	check_ADRESL
	goto	loop
	
check_ADRESL:
	;movlw	0xFA
	movf	buzzer_threshold_L, W, A
	cpfslt	ADRESL  ; Compare ADRESL with 0x2C, skip if ADRESH < 0x2C
	call	Buzzer
	return

GLCD_print_high_hour:
	bcf	PORTB, CS1 ;
	nop
	bsf	PORTB, CS2;set CS1 active
	nop
	
	movf    page_pointer, W, A ; 
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
	movlw	0xB9 ;start from second page
	movwf	page_pointer, A
	return
	    
not_last_page:; Increment the counter
	incf    page_pointer, F
	return
	
GLCD_print_temp_value:
	bcf	PORTB, CS2 ;
	nop
	bsf	PORTB, CS1;set CS2 active
	nop
	movf    page_pointer, W, A ; 
	call	send_command

	movlw	0x40 ; set to strip 0 in page (y-address)
	call	send_command
	call	spaces_bitmap
	call	spaces_bitmap
	movf	temp_reading_1, W, A
	call	compare_number
	goto	GLCD_print_temp_value_2
GLCD_print_temp_value_2:
	movf	temp_reading_2, W, A
	call	compare_number
	goto	GLCD_print_dot
GLCD_print_dot:
	call	dot
	goto	GLCD_print_temp_value_3
GLCD_print_temp_value_3:
	movf	temp_reading_3, W, A
	call	compare_number
	goto	GLCD_print_degree
GLCD_print_degree:
	call	degrees
	goto	GLCD_print_C
GLCD_print_C:
	call	letterC
	return

    
    
    
	
    


	
	
loop_clock_read:
	movlw	0x20
	movwf	spaces, A
	;call	first_line
	;read year
	call	RTCC_Get_Year
	call	bcd_to_ascii ;convert BCD to ASCII
	movff	high_nibble_ASCII, myArray + 1
	movff	low_nibble_ASCII, myArray + 2
	movff	spaces, POSTINC0
	movff	high_nibble_ASCII, POSTINC0
	movff	low_nibble_ASCII, POSTINC0

	
	
	;dash
	movlw	0x2D
	movwf	dash, A
	movff	dash, myArray + 3
	movff	dash, POSTINC0
	
	;read month
	call	RTCC_Get_Month
	call	bcd_to_ascii ;convert BCD to ASCII
	movff	high_nibble_ASCII, myArray + 4
	movff	low_nibble_ASCII, myArray + 5
	movff	high_nibble_ASCII, POSTINC0
	movff	low_nibble_ASCII, POSTINC0
	
	movff	dash, myArray + 6
	movff	dash, POSTINC0
	
	;read day
	call	RTCC_Get_Day
	call	bcd_to_ascii ;convert BCD to ASCII
	movff	high_nibble_ASCII, myArray + 7
	movff	low_nibble_ASCII, myArray + 8
	movff	high_nibble_ASCII, POSTINC0
	movff	low_nibble_ASCII, POSTINC0
	movff	spaces, POSTINC0
	
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
	movff	high_nibble_ASCII, POSTINC0
	movff	low_nibble_ASCII, POSTINC0
	
	;lfsr	0, dataArray
	;movff	high_nibble_ASCII, POSTINC0
	;movff	low_nibble_ASCII, POSTINC0
	
	movlw	0x3A	;ascii code for :
	movwf	colons, A
	movff	colons, myArray + 2
	movff	colons, POSTINC0
	
	call	RTCC_Get_Minutes    ; returns seconds value in W
	call	bcd_to_ascii ;convert BCD to ASCII
	movff	high_nibble_ASCII, myArray + 3
	movff	low_nibble_ASCII, myArray + 4
	movff	high_nibble_ASCII, high_minute
	movff	low_nibble_ASCII, low_minute
	movff	high_nibble_ASCII, POSTINC0
	movff	low_nibble_ASCII, POSTINC0

	movff	colons, myArray + 5
	movff	colons, POSTINC0
	
	call	RTCC_Get_Seconds
	call	bcd_to_ascii
	movff	high_nibble_ASCII, myArray + 6
	movff	low_nibble_ASCII, myArray + 7
	movff	high_nibble_ASCII, high_second
	movff	low_nibble_ASCII, low_second
	movff	high_nibble_ASCII, POSTINC0
	movff	low_nibble_ASCII, POSTINC0
	

	movff	spaces, myArray + 8
	movff	spaces, POSTINC0
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
	lfsr	0, dataArray
	banksel	PIR3
	btfss	PIR3, 0, A ;bit test file, skip if alarm interrupt flag is set
	retfie	f ;return from interrupt
	;
	bcf	PIR3, 0, A ;clear alarm interrupt flag
	;perform action
	incf	LATJ, F, A	; increment PORTD
	call	loop_clock_read
	call	ADC_Read
	call	page_setup
	call	GLCD_print_high_hour
	call	GLCD_print_temp_value
	call    multiplication
	call	mul24and8
	;movlw	0x0043		; scaling factor for temperature conversion
	;call	multiplication
	;call	mul24and8
	movlw	0x30		; ASCII code conversion
	addwf	RES3, F, A
	movff	RES3, myArray + 9
	movff	RES3, temp_reading_1
	movff	RES3, POSTINC0
	
	call	mul24and8
	movlw	0x30
	addwf	RES3, F, A
	movff	RES3, myArray + 10
	movff	RES3, temp_reading_2
	movff	RES3, POSTINC0
	
	call	mul24and8
	movlw	0x2E	;ascii code for .
	movwf	dot_ASCII, A
	movff	dot_ASCII, myArray + 11
	movff	dot_ASCII, POSTINC0
	movlw	0x30
	addwf	RES3, F, A
	movff	RES3, myArray + 12
	movff	RES3, temp_reading_3
	movff	RES3, POSTINC0
	
	movlw   0x0D              ; ASCII for Carriage Return (CR)
	movwf   POSTINC0          ; Add CR to myArray
	movlw   0x0A              ; ASCII for Line Feed (LF)
	movwf   POSTINC0          ; Add LF to myArray
	
	movlw	myTable_l
	lfsr	2, dataArray
	call	UART_Transmit_Message
	
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