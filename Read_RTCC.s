#include <xc.inc>

global	low_nibble_ASCII, high_nibble_ASCII, bcd_to_ascii
    
psect   udata_acs    ; Reserve data space in access RAM
bcd_output: ds   1
low_nibble_ASCII:   ds   1
high_nibble_ASCII:  ds   1
BCD_format: ds   1
    
psect   rtcc_code,class=CODE
; BCD output 8-bits
bcd_to_ascii:
    movwf   bcd_output          ; Store BCD number in bcd_output (A register)
    call    low_nibble          ; Convert low nibble of BCD to ASCII
    movwf   low_nibble_ASCII    ; Store the low nibble ASCII result
    call    high_nibble         ; Convert high nibble of BCD to ASCII
    movwf   high_nibble_ASCII   ; Store the high nibble ASCII result
    return

low_nibble:
    movf    bcd_output, W      ; Get the full BCD value into W register
    andlw   0x0F               ; Mask out the high nibble, keeping the low nibble
    call    to_ascii           ; Convert the low nibble to ASCII
    return

high_nibble:
    swapf   bcd_output, W      ; Swap high and low nibble, so high is in the lower nibble
    andlw   0x0F               ; Mask out the low nibble, keeping the high nibble
    call    to_ascii           ; Convert the high nibble to ASCII
    return

to_ascii:
    ; Convert a value (0-9) in W to its ASCII equivalent
    movwf   BCD_format         ; Copy the value in W (the BCD digit) into BCD_format for comparison
    movlw   0x30               ; Load W with the ASCII value for '0' (0x30)
    addwf   BCD_format, W      ; Add the ASCII value for '0' to the BCD value in BCD_format
    movwf   BCD_format         ; Store the result back in BCD_format
    return
