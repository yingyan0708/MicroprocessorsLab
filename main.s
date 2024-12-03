#include <xc.inc>

extrn	init_LCD, send_data, send_command

psect	udata_acs   ; reserve data space in access ram
counter:    ds 1    ; reserve one byte for a counter variable
delay_count:ds 1    ; reserve one byte for counter in the delay routine
count:	    ds 1

psect code, abs
rst:
	org	0x0
	goto	setup

; ******* Program Setup Code ***********************
setup:
	bcf	CFGS ; point to Flash program memory
	bsf	EEPGD ; access Flash program memory
	call	init_LCD
	call	clear_display
	goto	start

; ******* Main program ****************************************
start:
	movlw	0xB8 ; set to page 0 (x-address)
	call	send_command

	movlw	0x40 ; set to strip 0 in page (y-address)
	call	send_command
	call	letter_A
	call	letter_B
	goto	halt_program
letter_A:
	movlw	11111000B
	call	send_data
	
	movlw	00010100B
	call	send_data

	movlw	00010010B
	call	send_data
	
	movlw	00010001B
	call	send_data

	movlw	00010001B
	call	send_data
	
	movlw	00010010B
	call	send_data
	
	movlw	00010100B
	call	send_data
	
	movlw	11111000B
	call	send_data
	return

letter_B:
	movlw	00000000B
	call	send_data
	
	movlw	11111111B
	call	send_data
	
	movlw	10001001B
	call	send_data
	
	movlw	10001001B
	call	send_data
	
	movlw	01011010B
	call	send_data
	
	movlw	00100100B
	call	send_data
	
	movlw	00000000B
	call	send_data
	
	movlw	00000000B
	call	send_data
	return

halt_program:
	; Infinite loop to halt program execution

	goto	halt_program

; ******* Clear Display Routine ***********************
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

end
