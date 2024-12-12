#include <xc.inc>

global init_LCD, send_data, send_command,CS1,CS2,colon, compare_number, bcd_temp, dot,degrees, letterC, spaces_bitmap

psect	udata_acs
LCD_cnt_l:	ds 1   ; reserve 1 byte for variable LCD_cnt_l
LCD_cnt_h:	ds 1   ; reserve 1 byte for variable LCD_cnt_h
bcd_temp:	ds 1
RS  EQU	2 ;port B is control line
R   EQU 3 ;RW
EN  EQU	4
CS1 EQU	0
CS2 EQU	1
RST EQU	5

psect	glcd,class=CODE
   
init_LCD:
	clrf	PORTB, A
	clrf	PORTD, A
	clrf	LATD, A ;clear PORTD output latch (data lines)
	clrf	LATB, A ;clear PORTB output latch (control lines)
	clrf	TRISD, A ;Set all PORTD pins as outputs (data lines)
	clrf	TRISB, A

	bcf	PORTB, RST
	nop ;delay
	bsf	PORTB, RST
	nop ;delay

	movlw	0x3F ; Function Set: 8-bit, 128x64 resolution, normal display
	call	send_command

	movlw	0xB8 ;set to page 0 (x-address)
	call	send_command

	movlw	0x40 ;set to strip 0 in page (y-address)
	call	send_command

	movlw	0xC0 ;start line, start from row 0 (z-address)
	call	send_command

	
	return

send_command: ;RS and R/W are both 0 when sending command
	bcf	PORTB, RS, A ;clear RS
	nop
	nop
	bcf	PORTB, R, A ;clear RW
	nop
	nop
	movwf	PORTD ;store command in w, move command to port D where port D is data line
	bsf	PORTB, EN ;enable pin to 1
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	bcf	PORTB, EN
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	return

send_data: ;when writing/sending data, RS pin is set to 1
	bsf	PORTB, RS
	nop
	bcf	PORTB, R
	nop
	movwf	PORTD ;place data on port D
	bsf	PORTB, EN
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	bcf	PORTB, EN
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	movlw	10
	call	LCD_delay_x4us
	return

LCD_delay_x4us:		    ; delay given in chunks of 4 microsecond in W
	movwf	LCD_cnt_l, A	; now need to multiply by 16
	swapf   LCD_cnt_l, F, A	; swap nibbles
	movlw	0x0f	    
	andwf	LCD_cnt_l, W, A ; move low nibble to W
	movwf	LCD_cnt_h, A	; then to LCD_cnt_h
	movlw	0xf0	    
	andwf	LCD_cnt_l, F, A ; keep high nibble in LCD_cnt_l
	call	LCD_delay
	return

LCD_delay:			; delay routine	4 instruction loop == 250ns	    
	movlw 	0x00		; W=0
lcdlp1:	decf 	LCD_cnt_l, F, A	; no carry when 0x00 -> 0xff
	subwfb 	LCD_cnt_h, F, A	; no carry when 0x00 -> 0xff
	bc 	lcdlp1		; carry, then loop again
	return			; carry reset so return

compare_number:
        movwf     bcd_temp, A
        bra       check_0

check_0:
        movlw     0x30
        cpfseq    bcd_temp, A
        bra       check_1 
        call      num0
        return

check_1:
        movlw     0x31
        cpfseq    bcd_temp, A
        bra       check_2 
        call      num1
        return

check_2:
        movlw     0x32
        cpfseq    bcd_temp, A
        bra       check_3
        call      num2
        return

check_3:
        movlw     0x33
        cpfseq    bcd_temp, A
        bra       check_4 
        call      num3
        return

check_4:
        movlw     0x34
        cpfseq    bcd_temp, A
        bra       check_5 
        call      num4
        return

check_5: 
        movlw     0x35
        cpfseq    bcd_temp, A
        bra       check_6 
        call      num5
        return

check_6:
        movlw     0x36
        cpfseq    bcd_temp, A
              bra       check_7 
              call      num6
              return

check_7:
              movlw     0x37
              cpfseq    bcd_temp, A
              bra       check_8
              call      num7
              return

check_8:
              movlw     0x38
              cpfseq    bcd_temp, A
              bra       check_9
              call      num8
              return

check_9:
              movlw     0x39
              cpfseq    bcd_temp, A
              nop 
              call      num9
              return	
	
num0:
    movlw   00000000B
    call    send_data
    movlw   01111110B
    call    send_data
    movlw   10000001B
    call    send_data
    movlw   10000001B
    call    send_data
    movlw   10000001B
    call    send_data
    movlw   01111110B
    call    send_data
    movlw   00000000B
    call    send_data
    movlw   00000000B
    call    send_data
    return

num1:
    movlw   00000000B
    call    send_data
    movlw   00000000B
    call    send_data
    movlw   100000100B
    call    send_data
    movlw   10000010B
    call    send_data
    movlw   11111111B
    call    send_data
    movlw   10000000B
    call    send_data
    movlw   10000000B
    call    send_data
    movlw   00000000B
    call    send_data
    return

num2:
    movlw   00000000B
    call    send_data
    movlw   11000100B
    call    send_data
    movlw   10100010B
    call    send_data
    movlw   10010001B
    call    send_data
    movlw   10001001B
    call    send_data
    movlw   10000110B
    call    send_data
    movlw   00000000B
    call    send_data
    movlw   00000000B
    call    send_data
    return

num3:
    movlw   00000000B
    call    send_data
    movlw   01000010B
    call    send_data
    movlw   10001001B
    call    send_data
    movlw   10001001B
    call    send_data
    movlw   10011001B
    call    send_data
    movlw   01100110B
    call    send_data
    movlw   00000000B
    call    send_data
    movlw   00000000B
    call    send_data
    return

num4:
    movlw   00000000B
    call    send_data
    movlw   00010000B
    call    send_data
    movlw   00011000B
    call    send_data
    movlw   00010100B
    call    send_data
    movlw   00010010B
    call    send_data
    movlw   11111111B
    call    send_data
    movlw   00010000B
    call    send_data
    movlw   00000000B
    call    send_data
    return
    
num5:
    movlw   00000000B
    call    send_data
    movlw   01001111B
    call    send_data
    movlw   10001001B
    call    send_data
    movlw   10001001B
    call    send_data
    movlw   10001001B
    call    send_data
    movlw   01110001B
    call    send_data
    movlw   00000000B
    call    send_data
    movlw   00000000B
    call    send_data
    return

num6:
    movlw   00000000B
    call    send_data
    movlw   00111100B
    call    send_data
    movlw   01010010B
    call    send_data
    movlw   10001001B
    call    send_data
    movlw   10001001B
    call    send_data
    movlw   10001001B
    call    send_data
    movlw   01110000B
    call    send_data
    movlw   00000000B
    call    send_data
    return

num7:
    movlw   00000000B
    call    send_data
    movlw   10000001B
    call    send_data
    movlw   01000001B
    call    send_data
    movlw   00100001B
    call    send_data
    movlw   00010001B
    call    send_data
    movlw   00001001B
    call    send_data
    movlw   00000111B
    call    send_data
    movlw   00000000B
    call    send_data
    return

num8:
    movlw   00000000B
    call    send_data
    movlw   01110110B
    call    send_data
    movlw   10001001B
    call    send_data
    movlw   10001001B
    call    send_data
    movlw   10001001B
    call    send_data
    movlw   10001001B
    call    send_data
    movlw   01110110B
    call    send_data
    movlw   00000000B
    call    send_data
    return

num9:
    movlw   00000000B
    call    send_data
    movlw   10000110B
    call    send_data
    movlw   10001001B
    call    send_data
    movlw   10001001B
    call    send_data
    movlw   10001001B
    call    send_data
    movlw   01111110B
    call    send_data
    movlw   00000000B
    call    send_data
    movlw   00000000B
    call    send_data
    return

degrees:
    movlw   00000000B
    call    send_data
    movlw   00000000B
    call    send_data
    movlw   00000111B
    call    send_data
    movlw   00000101B
    call    send_data
    movlw   00000101B
    call    send_data
    movlw   00000111B
    call    send_data
    movlw   00000000B
    call    send_data
    movlw   00000000B
    call    send_data
    return
    
letterC:
    movlw   00000000B
    call    send_data
    movlw   01111110B
    call    send_data
    movlw   10000001B
    call    send_data
    movlw   10000001B
    call    send_data
    movlw   10000001B
    call    send_data
    movlw   10000001B
    call    send_data
    movlw   01000010B
    call    send_data
    movlw   00000000B
    call    send_data
    return

letterT:
    movlw   00000001B
    call    send_data
    movlw   00000001B
    call    send_data
    movlw   00000001B
    call    send_data
    movlw   11111111B
    call    send_data
    movlw   00000001B
    call    send_data
    movlw   00000001B
    call    send_data
    movlw   00000001B
    call    send_data
    movlw   00000000B
    call    send_data
    return

lettert:
    movlw   00000000B
    call    send_data
    movlw   00000000B
    call    send_data
    movlw   00001000B
    call    send_data
    movlw   00001000B
    call    send_data
    movlw   11111110B
    call    send_data
    movlw   00001000B
    call    send_data
    movlw   00001000B
    call    send_data
    movlw   00000000B
    call    send_data
    return


letterE:
    movlw   00000000B
    call    send_data
    movlw   01110000B
    call    send_data
    movlw   10101000B
    call    send_data
    movlw   10101000B
    call    send_data
    movlw   10101000B
    call    send_data
    movlw   10110000B
    call    send_data
    movlw   00000000B
    call    send_data
    movlw   00000000B
    call    send_data
    return


letterM:
    movlw   00000000B
    call    send_data
    movlw   11111000B
    call    send_data
    movlw   00001000B
    call    send_data
    movlw   11110000B
    call    send_data
    movlw   00001000B
    call    send_data
    movlw   11111000B
    call    send_data
    movlw   00000000B
    call    send_data
    movlw   00000000B
    call    send_data
    return

letterP:
    movlw   00000000B
    call    send_data
    movlw   00000000B
    call    send_data
    movlw   11111000B
    call    send_data
    movlw   00101000B
    call    send_data
    movlw   00101000B
    call    send_data
    movlw   00010000B
    call    send_data
    movlw   00000000B
    call    send_data
    movlw   00000000B
    call    send_data
    return
    
letterR:
    movlw   00000000B
    call    send_data
    movlw   11111000B
    call    send_data
    movlw   00010000B
    call    send_data
    movlw   00001000B
    call    send_data
    movlw   00001000B
    call    send_data
    movlw   00010000B
    call    send_data
    movlw   00000000B
    call    send_data
    movlw   00000000B
    call    send_data
    return

letterU:
    movlw   00000000B
    call    send_data
    movlw   00111000B
    call    send_data
    movlw   01000000B
    call    send_data
    movlw   10000000B
    call    send_data
    movlw   10000000B
    call    send_data
    movlw   01000000B
    call    send_data
    movlw   11111000B
    call    send_data
    movlw   00000000B
    call    send_data
    return

letterA:
    movlw   00000000B
    call    send_data
    movlw   01001000B
    call    send_data
    movlw   10101000B
    call    send_data
    movlw   10101000B
    call    send_data
    movlw   10101000B
    call    send_data
    movlw   01110000B
    call    send_data
    movlw   00000000B
    call    send_data
    movlw   00000000B
    call    send_data
    return

letterI:
    movlw   00000000B
    call    send_data
    movlw   00000000B
    call    send_data
    movlw   00000000B
    call    send_data
    movlw   11110110B
    call    send_data
    movlw   11110110B
    call    send_data
    movlw   00000000B
    call    send_data
    movlw   00000000B
    call    send_data
    movlw   00000000B
    call    send_data
    return

colon:
    movlw   00000000B
    call    send_data
    movlw   00000000B
    call    send_data
    movlw   00000000B
    call    send_data
    movlw   01100110B
    call    send_data
    movlw   01100110B
    call    send_data
    movlw   00000000B
    call    send_data
    movlw   00000000B
    call    send_data
    movlw   00000000B
    call    send_data
    return

dash:
    movlw   00000000B
    call    send_data
    movlw   00001000B
    call    send_data
    movlw   00001000B
    call    send_data
    movlw   00001000B
    call    send_data
    movlw   00001000B
    call    send_data
    movlw   00001000B
    call    send_data
    movlw   00001000B
    call    send_data
    movlw   00000000B
    call    send_data
    return

dot:
    movlw   00000000B
    call    send_data
    movlw   00000000B
    call    send_data
    movlw   00000000B
    call    send_data
    movlw   11000000B
    call    send_data
    movlw   11000000B
    call    send_data
    movlw   00000000B
    call    send_data
    movlw   00000000B
    call    send_data
    movlw   00000000B
    call    send_data
    return

spaces_bitmap:
    movlw   00000000B
    call    send_data
    movlw   00000000B
    call    send_data
    movlw   00000000B
    call    send_data
    movlw   00000000B
    call    send_data
    movlw   00000000B
    call    send_data
    movlw   00000000B
    call    send_data
    movlw   00000000B
    call    send_data
    movlw   00000000B
    call    send_data
    return
end

