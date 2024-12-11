    ; Include necessary headers
#include <xc.inc>

    ; Define constants for configuration and delays
#define FREQ_PWM 1000  ; Frequency of the PWM signal in Hz (1kHz)
#define TIMER_PRESCALE 16  ; Timer prescaler to achieve 1-second delay
    
    ; Define global variables (for counter)
global _start, PWMOn, Delay1Second, PWMOff  
org 0x00

_start:
    ; Initial setup for the device
    call InitPWM   ; Call PWM initialization
    call InitTimer ; Call Timer initialization for 1 second delay
    
    ; Main program loop
MainLoop:
    call PWMOn  ; Start PWM output
    call Delay1Second ; Wait for 1 second 
    call PWMOff  ; Stop PWM output
    return
  
InitPWM:
    ; Set the appropriate registers for PWM mode
    bcf     TRISB, 6         ; Set RB6 as output (for buzzer)
    movlw   0x0F             ; Set PR2 register to maximum for PWM
    movwf   PR2              ; PWM frequency setup (depends on clock and prescaler)
    
    movlw   0x00             ; Set duty cycle to 50% (adjustable)
    movwf   CCPR1L           ; Load CCP register with 50% duty cycle
    bsf     CCP1CON, 4       ; Set PWM mode for CCP1
    bsf     CCP1CON, 5
    
    return

; Initialize Timer (Timer0 example for 1-second delay)
InitTimer:
    movlw   0x03             ; Prescaler = 16 
    movwf   T0CON            ; Set prescaler
    bsf     T0CON, 0         ; Enable Timer0
    bcf     T0CON, 1         ; Set 8-bit mode
    bsf     T0CON, 2         ; Enable Timer0 interrupt 
    return

; Start PWM signal generation
PWMOn:
    bsf	    PORTH, 0, A
    bsf     T2CON, 2         ; Start Timer2 to trigger PWM output
    return

; Stop PWM signal generation
PWMOff:
    bcf	    PORTH, 0, A
    bcf     T2CON, 2         ; Stop Timer2 
    return

; 1-second delay using Timer0
Delay1Second:
    ; Wait for 1 second
WaitLoop:
    btfss   INTCON, 2          ; Check if Timer0 overflowed (1 second passed)
    goto    WaitLoop         ; Loop until Timer0 overflows
    bcf     INTCON, 2          ; Clear the interrupt flag
    return
