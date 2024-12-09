#include <xc.inc>
    
psect	udata_acs

psect	buzzer_code, class=CODE

PWM_Setup:
    ;set up PR2 value 
    banksel PR2
    movlw   0xFF
    movwf   PR2, B
    
    ;set up PWM duty cycle
    banksel CCP4CON
    banksel CCPR4L
    bcf	    CCP4CON, 4
    bcf	    CCP4CON, 5
    movlw   10000000B
    movwf   CCPR4L, B
    
    ;Prescale value 16
    banksel TMR2
    movlw   00010000B ;prescale value = 16
    movwf   TMR2, B
    
    banksel T2CON
    bsf	    T2CON, 2
    
    banksel CCP4CON
    movlw   0x0C ;CCP4M = 1100
    movwf   CCP4CON, B
    
    bcf	    TRSIB, 6 ;set RB6 as output for piezo buzzer
    
