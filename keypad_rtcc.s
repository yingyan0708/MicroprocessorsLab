#include <xc.inc>
    
global keypad_setup, keypad_read, alarm_mask, buzzer_threshold_L, buzzer_threshold_H
extrn	DELAY
psect	 udata_acs
kp:			ds	1
ROW:			ds	1
buzzer_threshold_L:	ds	1
buzzer_threshold_H:	ds	1
alarm_mask:	ds	1

psect	 uart_code, class=CODE
keypad_setup:
    banksel PADCFG1 ;select bank RAM
    bsf	    REPU ;set REPU pin to 1
    clrf    LATE, A ;clear latch
    clrf    TRISJ, A ;set PORTJ as output, for debugging purpose
    return
    
keypad_read:
    movlw   0x0F    ;configure PORTE pin 4-7 as outputs and pin 0-3 as inputs
    movwf   TRISE, A
    call    KeyPad_delay ;call delay for voltage on output pins to settle
    movf    PORTE, W, A    ;move output from PORTE to W register
    movwf   ROW, A    ;save output in ROW file register
    movlw   0xF0    ;configure PORTE pin 4-7 as inputs and pin 0-3 as outputs
    movwf   TRISE, A    
    call    KeyPad_delay    ;call delay for output pins to settle
    movf    PORTE, W, A    ;move output from PORTE to W register
    addwf   ROW, F, A    ;add W register with value stored in ROW, save the results in ROW file register
    bra	    check_1    ;decode the output value to check which button was pressed
    ;return
    
check_1:
    movlw   01110111B ;decode for 1
    cpfseq  ROW, A    ;compare if the value is the same as W register, skip next instruction if it is equal
    bra	    check_2
    movlw   0x00
    movwf   buzzer_threshold_H, A
    movlw   0xFA
    movwf   buzzer_threshold_L, A ;sets the buzzer threshold to 25 degrees Celsius
    movlw   11000100B
    movwf   alarm_mask, A ;every second
    return
    
check_2:
    movlw   10110111B ;2
    cpfseq  ROW, A
    bra	    check_3
    movlw   0x01
    movwf   buzzer_threshold_H, A
    movlw   0x0E
    movwf   buzzer_threshold_L, A ;sets the buzzer threshold to 27 degrees Celsius
    movlw   11001000B
    movwf   alarm_mask, A ;every 10 seconds
    return
    
check_3:
    movlw   11010111B ;3
    cpfseq  ROW, A
    bra	    null
    movlw   0x01
    movwf   buzzer_threshold_H, A
    movlw   0x2C
    movwf   buzzer_threshold_L, A ;sets the buzzer threshold to 30 degrees Celsius
    movlw   11001100B
    movwf   alarm_mask, A ;every minute
    return

    
null:
    movlw   11111111B
    cpfseq  ROW, A
    return
    goto    keypad_read
   

  
KeyPad_delay:
    movlw   50
    movwf   kp, A
KeyPad_Loop_delay:
    decfsz  kp, A
    bra	    KeyPad_Loop_delay
    return
    
end
