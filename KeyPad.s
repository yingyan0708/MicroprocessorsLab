#include <xc.inc>
    
global  KeyPad_Setup, KeyPad_Read

psect	udata_acs   ; reserve data space in access ram
KeyPad_counter: ds    1	    ; reserve 1 byte for variable UART_counter
ROW:		ds    1

psect	uart_code,class=CODE
KeyPad_Setup:
    banksel PADCFG1
    bsf	    REPU
    clrf    LATE, A
    clrf    TRISH, A
    return
    
KeyPad_Read:
    movlw   0x0F	; set RE0,RE1,RE2,RE3 as input
    movwf   TRISE, A
    call    KeyPad_delay
    movf    PORTE, W, A
    movwf   ROW, A
    movlw   0xF0
    movwf   TRISE, A
    call    KeyPad_delay
    movf    PORTE, W, A
    addwf   ROW, F, A
    movff   ROW, PORTH
    return
    
check_1:
    movlw   01110111B ;1
    cpfseq  ROW, A
    bra	    check_2
    retlw   '1'
check_2:
;    01111011B ;2
;    01111101B ;3
;    01111110B ;F
;    10110111B ;4
;    10111011B ;5
;    10111101B ;6
;    10111110B ;E
;    11010111B ;7
;    11011011B ;8
;    11011101B ;9
;    11011110B ;D
;    11100111B ;A
;    11101011B ;0
;    11101101B ;B
;    11101110B ;C
;    11111111B ;null


 
    
	
    bsf	    SPEN	; enable
    bcf	    SYNC	; synchronous
    bcf	    BRGH	; slow speed
    bsf	    TXEN	; enable transmit
    bcf	    BRG16	; 8-bit generator only
    movlw   103		; gives 9600 Baud rate (actually 9615)
    movwf   SPBRG1, A	; set baud rate
    bsf	    TRISC, PORTC_TX1_POSN, A	; TX1 pin is output on RC6 pin
					; must set TRISC6 to 1
    return

KeyPad_delay:	    ; Message stored at FSR2, length stored in W
    movlw   50
    movwf   KeyPad_counter, A
KeyPad_Loop_delay:
    decfsz  KeyPad_counter, A
    bra	    KeyPad_Loop_delay
    return

;KeyPad_Transmit_Byte:	    ; Transmits byte stored in W
;    btfss   TX1IF	    ; TX1IF is set when TXREG1 is empty
;    bra	    KeyPad_Transmit_Byte
;    movwf   TXREG1, A
;    return




