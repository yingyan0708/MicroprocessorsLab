#include <xc.inc>

extrn init_LCD, send_data
    
psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
myTable_add:    ds 0x80 ; reserve 128 bytes for message data


psect	data    
	; ******* myTable, data in programme memory, and its length *****
myTable:
	db	'H','e','l','l','o',' ','W','o','r','l','d','!',0x0a
					; message, plus carriage return
	myTable_l   EQU	13	; length of data

psect code, abs   
rst:	org	0x0
	goto	setup
; ******* Programme FLASH read Setup Code ***********************
setup:  
	call	init_LCD   ; Initialize the LCD
	
table:
    ; Initialize FSR0 to point to myTable (Program Memory)
	lfsr	0, myTable_add  ; Load the address of myTable into FSR0

    ; Loop through the string in program memory
	movf	myTable_l, W    ; Load the length of the string into W
	movwf	0x20            ; Store it in temporary register (0x20)
    
    ; Start reading the string from program memory
table_loop:
	movf   0x20, W         ; Check if we have processed the entire string
	bz     End_String      ; If W is zero, we've finished

    ; Read the next byte from program memory (FSR0 is used to point to myTable)
	movf   INDF0, W        ; Get the character from program memory
	call   send_data       ; Send the character to LCD
    
	incf   FSR0, f         ; Increment FSR0 to the next character in the table
	decfsz 0x20, f         ; Decrement string length and check if we're done
	bra    table_loop      ; If not, continue looping

End_String:
	return
	;bcf CFGS        ; point to Flash program memory  
	;bsf EEPGD       ; access Flash program memory

;send:    
	;movlw	0xAA      ; Load W register with 0xAA
	;call	send_data  ; Send the data to LCD
	;call	delay      ; Optional delay to allow LCD to process the data
	;goto	send   ; Infinite loop to keep sending data

delay:
	movlw	0xFF      ; Set the delay counter value (adjust as needed)
	movwf	0x20
delay_loop:
	decfsz	0x20, F  ; Decrement counter, skip if zero
	bra	delay_loop  ; Repeat loop if not zero
	return

