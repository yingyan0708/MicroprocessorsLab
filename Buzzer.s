#include <xc.inc>
    
psect	udata_acs

psect	buzzer_code, class=CODE

PWM_Setup:
    movlw   0xFF
    movwf   PR2

    bsf	    CCP4CON, 4
    bsf	    CCP4CON, 5
    CCPR4L
    
    ;Prescale value 16
    movlw   00010000B ;prescale value
    movwf   TMR2
    
    bsf	    T2CON, 2
