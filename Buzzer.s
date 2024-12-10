#include <xc.inc>
global	PWM_Setup
psect	udata_acs

psect	buzzer_code, class=CODE

PWM_Setup:
    ;set up PR2 value 
    banksel PR2
    movlw   0xFF ;255
    movwf   PR2, B
    
    ;set up PWM duty cycle
    banksel CCP4CON
    banksel CCPR4L
    bcf	    CCP4CON, 4, B
    bcf	    CCP4CON, 5, B
    movlw   00100000B ;set 50% duty cycle
    movwf   CCPR4L, B
    

    banksel CCPTMRS1
    bcf	    CCPTMRS1, 1, B
    bcf     CCPTMRS1, 0, B	    
    
    movlw   00000110B
    movwf   T2CON ;on timer2, prescale value 16
    
    banksel CCP4CON
    movlw   0x0C ;CCP4M = 1100
    movwf   CCP4CON, B
    
    bcf	    TRISB, 6 ;set RB6 as output for piezo buzzer
    return
    
