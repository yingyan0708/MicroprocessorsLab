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
	goto	start
; ******* Main programme ****************************************
start: ;display character A
	movlw	0xB8 ;set to page 0 (x-address)
	call	send_command

	movlw	0x40 ;set to strip 0 in page (y-address)
	call	send_command
	
	movlw	0x40
	movwf	count, A
loop:	
	decfsz	count
	call	clear
	bra	loop
	
clear:
	movlw	0xFF
	call	send_data
	return
	

end	rst