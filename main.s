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
; ******* Programme FLASH read Setup Code ***********************
setup:
	bcf	CFGS; point to Flash program memory  
	bsf	EEPGD ; access Flash program memory
	call	init_LCD
	call	clear_display
	goto	start
; ******* Main programme ****************************************
	
start:
	movlw	0xB8 ;set to page 0 (x-address)
	call	send_command

	movlw	0x40 ;set to strip 0 in page (y-address)
	call	send_command
	
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
	
	goto	halt_program

halt_program:
	; Add an infinite loop to stop the program from running
	goto	halt_program
	
    
clear_display: ;display character A
	movlw	0xB8 ;set to page 0 (x-address)
	call	send_command

	movlw	0x40 ;set to strip 0 in page (y-address)
	call	send_command
	
	movlw	0x40
	movwf	count, A
loop1:	
	call	clear
	decfsz	count
	bra	loop1
	goto	page2

page2:
	movlw	0xB9 ;set to page 0 (x-address)
	call	send_command

	movlw	0x40 ;set to strip 0 in page (y-address)
	call	send_command
	
	movlw	0x40
	movwf	count, A
loop2:	
	call	clear
	decfsz	count
	bra	loop2
	return
	
clear:
	movlw	0x00
	call	send_data
	return
	

end	rst