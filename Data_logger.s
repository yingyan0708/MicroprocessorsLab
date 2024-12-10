#include <xc.inc>

global new_data_logger

psect	udata_acs
temp_data:  ds  4

psect	data_logger,class=CODE
;data_logger:
            ;movlw  0xFF      
            ;movwf  EEADR, A                ;register low byte
            ;movlw  high(temp_data)
            ;movwf  EEADRH, A               ;register high byte
            ;movlw  temp_data              
            ;movwf  EEDATA, A               ;EEPROM data register
            
;program_memory:
            ;bcf    EECON1, 7, A            ;EEPGD, access data EEPROM memory
            ;bcf    EECON1, 6, A            ;CFGS, access data EEPROM
            ;bsf    EECON1, 2, A            ;WREN, write cycles to EEPROM
            
            ;bcf   INTCON, GIE, A             ;disable interrupts
            ;movlw  0x55                    ;required sequence from the data sheet
            ;movwf  EECON2, A
            ;movlw  0xAA
            ;movwf  EECON2, A
            ;bsf    EECON1, 1, A            ;WR, initiates a EEPROM write cycle
            ;btfsc  EECON1, 1, A
            ;bsf   INTCON, GIE, A             ;re-enable interrupts
            ;bcf    EECON1, 2, A            ;WREN, disable writes
            ;return
	    
new_data_logger:
	    clrf	EEADR, A
	    clrf	EEADRH, A
	    bcf		EECON1, 7, A            ;EEPGD, access data EEPROM memory
            bcf		EECON1, 6, A            ;CFGS, access data EEPROM
	    bcf		INTCON, 7, A		   ;disable interrupts
            bsf		EECON1, 2, A            ;WREN, write cycles to EEPROM
	    
new_loop:
	    ;bsf		EECON1, 0, A
	    movlw	0x55                    ;required sequence from the data sheet
            movwf	EECON2, A
            movlw	0xAA
            movwf	EECON2, A
	    bsf		EECON1, 1, A            ;WR, initiates a EEPROM write cycle
	    
            btfsc	EECON1, 1, A
	    bra		$-2
	    incfsz	EEADR, F
	    bra		new_loop
	    
	    bcf		EECON1, 2, A            ;disable WREN
	    bsf		INTCON, 7, A
	    return
