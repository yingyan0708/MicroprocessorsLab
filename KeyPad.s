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
    bra	    check_1
    ;return
    
check_1:
    movlw   01110111B ;1
    cpfseq  ROW, A
    bra	    check_2
    retlw   '1'
    return
    
check_2:
    movlw   10110111B ;2
    cpfseq  ROW, A
    bra	    check_3
    retlw   '2'
    return
    
check_3:
    movlw   11010111B ;3
    cpfseq  ROW, A
    bra	    check_4
    retlw   '3'
    return
    
check_4:
    movlw   01111011B ;4
    cpfseq  ROW, A
    bra	    check_5
    retlw   '4'
    return
    
check_5:
    movlw   10111011B ;5
    cpfseq  ROW, A
    bra	    check_6
    retlw   '5'
    return
    
check_6:
    movlw   11011011B ;6
    cpfseq  ROW, A
    bra	    check_7
    retlw   '6'
    return
    
check_7:
    movlw   01111101B ;7
    cpfseq  ROW, A
    bra	    check_8
    retlw   '7'
    return
    
check_8:
    movlw   10111101B ;8
    cpfseq  ROW, A
    bra	    check_9
    retlw   '8'
    return

check_9:
    movlw   11011101B ;9
    cpfseq  ROW, A
    bra	    check_0
    retlw   '9'
    return
    
check_0:
    movlw   10111110B ;0
    cpfseq  ROW, A
    bra	    check_A
    retlw   '0'
    return
    
check_A:
    movlw   01111110B ;A
    cpfseq  ROW, A
    bra	    check_B
    retlw   'A'
    return
    
check_B:
    movlw   11011110B ;B
    cpfseq  ROW, A
    bra	    check_C
    retlw   'B'
    return
    
check_C:
    movlw   11101110B ;C
    cpfseq  ROW, A
    bra	    check_D
    retlw   'C'
    return
    
check_D:
    movlw   11101101B ;D
    cpfseq  ROW, A
    bra	    check_E
    retlw   'D'
    return
    
check_E:
    movlw   11101011B ;E
    cpfseq  ROW, A
    bra	    check_F
    retlw   'E'
    return
    
check_F:
    movlw   11100111B ;F
    cpfseq  ROW, A
    bra	    check_null
    retlw   'F'
    return

check_null:
    movlw   11111111B ;null
    cpfseq  ROW, A  
    goto    KeyPad_Read
    retlw   'N'
    return


    ;bsf	    SPEN	; enable
    ;bcf	    SYNC	; synchronous
    ;bcf	    BRGH	; slow speed
    ;bsf	    TXEN	; enable transmit
    ;cf	    BRG16	; 8-bit generator only
    ;movlw   103		; gives 9600 Baud rate (actually 9615)
    ;movwf   SPBRG1, A	; set baud rate
    ;bsf	    TRISC, PORTC_TX1_POSN, A	; TX1 pin is output on RC6 pin
					; must set TRISC6 to 1

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




