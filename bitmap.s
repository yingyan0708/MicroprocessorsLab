num0:
    movlw   00000000B
    call    GLCD_SendCommand
    movlw   00000000B
    call    GLCD_SendCommand
    movlw   01111110B
    call    GLCD_SendCommand
    movlw   10000001B
    call    GLCD_SendCommand
    movlw   10000001B
    call    GLCD_SendCommand
    movlw   10000001B
    call    GLCD_SendCommand
    movlw   01111110B
    call    GLCD_SendCommand
    movlw   00000000B
    call    GLCD_SendCommand

num1:
    movlw   00000000B
    call    GLCD_SendCommand
    movlw   00000001B
    call    GLCD_SendCommand
    movlw   00000001B
    call    GLCD_SendCommand
    movlw   11111111B
    call    GLCD_SendCommand
    movlw   01000001B
    call    GLCD_SendCommand
    movlw   00100001B
    call    GLCD_SendCommand
    movlw   00000000B
    call    GLCD_SendCommand
    movlw   00000000B
    call    GLCD_SendCommand

num2:
    movlw   00000000B
    call    GLCD_SendCommand
    movlw   00000000B
    call    GLCD_SendCommand
    movlw   01100001B
    call    GLCD_SendCommand
    movlw   10010001B
    call    GLCD_SendCommand
    movlw   10001001B
    call    GLCD_SendCommand
    movlw   01000101B
    call    GLCD_SendCommand
    movlw   00100011B
    call    GLCD_SendCommand
    movlw   00000000B
    call    GLCD_SendCommand

num3:
    movlw   00000000B
    call    GLCD_SendCommand
    movlw   00000000B
    call    GLCD_SendCommand
    movlw   01100110B
    call    GLCD_SendCommand
    movlw   10011001B
    call    GLCD_SendCommand
    movlw   10010001B
    call    GLCD_SendCommand
    movlw   10010001B
    call    GLCD_SendCommand
    movlw   01000010B
    call    GLCD_SendCommand
    movlw   00000000B
    call    GLCD_SendCommand

num4:
    movlw   00000000B
    call    GLCD_SendCommand
    movlw   00001000B
    call    GLCD_SendCommand
    movlw   11111111B
    call    GLCD_SendCommand
    movlw   01001000B
    call    GLCD_SendCommand
    movlw   00101000B
    call    GLCD_SendCommand
    movlw   00011000B
    call    GLCD_SendCommand
    movlw   00001000B
    call    GLCD_SendCommand
    movlw   00000000B
    call    GLCD_SendCommand
    
num5:
    movlw   00000000B
    call    GLCD_SendCommand
    movlw   00000000B
    call    GLCD_SendCommand
    movlw   10001110B
    call    GLCD_SendCommand
    movlw   10010001B
    call    GLCD_SendCommand
    movlw   10010001B
    call    GLCD_SendCommand
    movlw   10010001B
    call    GLCD_SendCommand
    movlw   11110010B
    call    GLCD_SendCommand
    movlw   00000000B
    call    GLCD_SendCommand

num6:
    movlw   00000000B
    call    GLCD_SendCommand
    movlw   00001110B
    call    GLCD_SendCommand
    movlw   10010001B
    call    GLCD_SendCommand
    movlw   10010001B
    call    GLCD_SendCommand
    movlw   10010001B
    call    GLCD_SendCommand
    movlw   01001010B
    call    GLCD_SendCommand
    movlw   00111100B
    call    GLCD_SendCommand
    movlw   00000000B
    call    GLCD_SendCommand

num7:
    movlw   00000000B
    call    GLCD_SendCommand
    movlw   11100000B
    call    GLCD_SendCommand
    movlw   10010000B
    call    GLCD_SendCommand
    movlw   10001000B
    call    GLCD_SendCommand
    movlw   10000100B
    call    GLCD_SendCommand
    movlw   10000010B
    call    GLCD_SendCommand
    movlw   10000001B
    call    GLCD_SendCommand
    movlw   00000000B
    call    GLCD_SendCommand

num8:
    movlw   00000000B
    call    GLCD_SendCommand
    movlw   01101110B
    call    GLCD_SendCommand
    movlw   10010001B
    call    GLCD_SendCommand
    movlw   10010001B
    call    GLCD_SendCommand
    movlw   10010001B
    call    GLCD_SendCommand
    movlw   10010001B
    call    GLCD_SendCommand
    movlw   01101110B
    call    GLCD_SendCommand
    movlw   00000000B
    call    GLCD_SendCommand

num9:
    movlw   00000000B
    call    GLCD_SendCommand
    movlw   00000000B
    call    GLCD_SendCommand
    movlw   01111110B
    call    GLCD_SendCommand
    movlw   10010001B
    call    GLCD_SendCommand
    movlw   10010001B
    call    GLCD_SendCommand
    movlw   10010001B
    call    GLCD_SendCommand
    movlw   01100001B
    call    GLCD_SendCommand
    movlw   00000000B
    call    GLCD_SendCommand

degrees:
    movlw   00000000B
    call    GLCD_SendCommand
    movlw   00000000B
    call    GLCD_SendCommand
    movlw   00000000B
    call    GLCD_SendCommand
    movlw   11100000B
    call    GLCD_SendCommand
    movlw   10100000B
    call    GLCD_SendCommand
    movlw   11100000B
    call    GLCD_SendCommand
    movlw   00000000B
    call    GLCD_SendCommand
    movlw   00000000B
    call    GLCD_SendCommand
    
letterC:
    movlw   00000000B
    call    GLCD_SendCommand
    movlw   01000010B
    call    GLCD_SendCommand
    movlw   10000001B
    call    GLCD_SendCommand
    movlw   10000001B
    call    GLCD_SendCommand
    movlw   10000001B
    call    GLCD_SendCommand
    movlw   10000001B
    call    GLCD_SendCommand
    movlw   01111110B
    call    GLCD_SendCommand
    movlw   00000000B
    call    GLCD_SendCommand

letterT:
    movlw   00000000B
    call    GLCD_SendCommand
    movlw   00010000B
    call    GLCD_SendCommand
    movlw   00010000B
    call    GLCD_SendCommand
    movlw   01111111B
    call    GLCD_SendCommand
    movlw   00010000B
    call    GLCD_SendCommand
    movlw   00010000B
    call    GLCD_SendCommand
    movlw   00000000B
    call    GLCD_SendCommand
    movlw   00000000B
    call    GLCD_SendCommand

letterE:
    movlw   00000000B
    call    GLCD_SendCommand
    movlw   00000000B
    call    GLCD_SendCommand
    movlw   00001101B
    call    GLCD_SendCommand
    movlw   00010101B
    call    GLCD_SendCommand
    movlw   00010101B
    call    GLCD_SendCommand
    movlw   00010101B
    call    GLCD_SendCommand
    movlw   00001110B
    call    GLCD_SendCommand
    movlw   00000000B
    call    GLCD_SendCommand
    
letterM:
    movlw   00000000B
    call    GLCD_SendCommand
    movlw   00000000B
    call    GLCD_SendCommand
    movlw   00011111B
    call    GLCD_SendCommand
    movlw   00010000B
    call    GLCD_SendCommand
    movlw   00001111B
    call    GLCD_SendCommand
    movlw   00010000B
    call    GLCD_SendCommand
    movlw   00011111B
    call    GLCD_SendCommand
    movlw   00000000B
    call    GLCD_SendCommand

letterP:
    movlw   00000000B
    call    GLCD_SendCommand
    movlw   00000000B
    call    GLCD_SendCommand
    movlw   00001000B
    call    GLCD_SendCommand
    movlw   00010100B
    call    GLCD_SendCommand
    movlw   00010100B
    call    GLCD_SendCommand
    movlw   00011111B
    call    GLCD_SendCommand
    movlw   00000000B
    call    GLCD_SendCommand
    movlw   00000000B
    call    GLCD_SendCommand
    
letterR:
    movlw   00000000B
    call    GLCD_SendCommand
    movlw   00000000B
    call    GLCD_SendCommand
    movlw   00001000B
    call    GLCD_SendCommand
    movlw   00010000B
    call    GLCD_SendCommand
    movlw   00010000B
    call    GLCD_SendCommand
    movlw   00001000B
    call    GLCD_SendCommand
    movlw   00011111B
    call    GLCD_SendCommand
    movlw   00000000B
    call    GLCD_SendCommand

letterU:
    movlw   00000000B
    call    GLCD_SendCommand
    movlw   00011111B
    call    GLCD_SendCommand
    movlw   00000010B
    call    GLCD_SendCommand
    movlw   00000001B
    call    GLCD_SendCommand
    movlw   00000001B
    call    GLCD_SendCommand
    movlw   00000010B
    call    GLCD_SendCommand
    movlw   00011100B
    call    GLCD_SendCommand
    movlw   00000000B
    call    GLCD_SendCommand

letterA:
    movlw   00000000B
    call    GLCD_SendCommand
    movlw   00000000B
    call    GLCD_SendCommand
    movlw   00001110B
    call    GLCD_SendCommand
    movlw   00010101B
    call    GLCD_SendCommand
    movlw   00010101B
    call    GLCD_SendCommand
    movlw   00010101B
    call    GLCD_SendCommand
    movlw   00010010B
    call    GLCD_SendCommand
    movlw   00000000B
    call    GLCD_SendCommand

colon:
    movlw   00000000B
    call    GLCD_SendCommand
    movlw   00000000B
    call    GLCD_SendCommand
    movlw   00000000B
    call    GLCD_SendCommand
    movlw   01100110B
    call    GLCD_SendCommand
    movlw   01100110B
    call    GLCD_SendCommand
    movlw   00000000B
    call    GLCD_SendCommand
    movlw   00000000B
    call    GLCD_SendCommand
    movlw   00000000B
    call    GLCD_SendCommand

dash:
    movlw   00000000B
    call    GLCD_SendCommand
    movlw   00010000B
    call    GLCD_SendCommand
    movlw   00010000B
    call    GLCD_SendCommand
    movlw   00010000B
    call    GLCD_SendCommand
    movlw   00010000B
    call    GLCD_SendCommand
    movlw   00010000B
    call    GLCD_SendCommand
    movlw   00010000B
    call    GLCD_SendCommand
    movlw   00000000B
    call    GLCD_SendCommand

