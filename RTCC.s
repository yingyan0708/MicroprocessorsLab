#include <xc.inc>
    
global  RTCC_Setup, RTCC_Get_Seconds, RTCC_Get_Minutes

psect	udata_acs   ; reserve data space in access ram
RTCC_seconds: ds    1	    ; reserve 1 byte for seconds
RTCC_minutes: ds    1	    ; reserve 1 byte for minutes
RTCC_hours: ds	    1	    ; reserve 1 byte for hours
    
psect	rtcc_code,class=CODE
RTCC_Setup:
    banksel RTCCFG	; RTCC SFRs are not in access ram
    movlw   0x55    ;first unlock key
    movwf   EECON2
    movlw   0xAA
    movwf   EECON2
    bsf	    RTCCFG, 5, B ;enable RTCWREN
    bsf	    RTCCFG, 7, B ;enable RTCEN
    bsf	    RTSECSEL1	; RTSECSELx bits determine output on RTCC pin
    bcf	    RTSECSEL0	; 10 outputs the source clock, 01 outputs second count
    bsf	    RTCCFG, 2, B ;enable RTCOE
    call    RTCC_set_Seconds
    call    RTCC_set_Minutes
    bcf	    RTCCFG, 5, B ;disable RTCWREN
    bsf	    RTSECSEL1	; RTSECSELx bits determine output on RTCC pin
    bcf	    RTSECSEL0	; 10 outputs the source clock, 01 outputs second count
    movlb   0		; reset BSR to 0
    return

RTCC_Get_Seconds:	; Reads and stores seconds value in RTCC_Seconds
			; Also returns the value in W register
    banksel RTCCFG	; RTCC SFRs are not in access ram
    ;read year (RTCPTR = 11)
    BCF	   RTCPTR1	; Clear RTCPTR1 and RTCPTR0 for seconds output
    bcf	    RTCPTR0
    movf    RTCVALL,W,B ;Read minutes from RTCVALH 
    ;movwf   RTCC_seconds, A ; Store value in RTCC_Seconds variable space
    ;movf    RTCVALH, W, B   ; Read minutes from RTCVALH 
    ;movwf   RTCC_minutes, A	; Store value in RTCC_Minutes variable space
    movlb   0		; reset BSR to 0
    return

RTCC_Get_Minutes:	; Reads and stores seconds value in RTCC_Seconds
			; Also returns the value in W register
    banksel RTCCFG	; RTCC SFRs are not in access ram
    ;read year (RTCPTR = 11)
    bcf	    RTCPTR1	; Clear RTCPTR1 and RTCPTR0 for seconds output
    bcf	    RTCPTR0
    movf    RTCVALH, W, B   ; Read minutes from RTCVALH 
    movlb   0		; reset BSR to 0
    return

RTCC_set_Seconds:
    banksel RTCCFG
    bcf	    RTCCFG, 5, B ;enable RTCWREN
    bcf	    RTCPTR1	; Clear RTCPTR1 and RTCPTR0 for seconds output
    bcf	    RTCPTR0
    movlw   00000000B
    movwf   RTCVALL, B   ; Read minutes from RTCVALH 
    return
    
RTCC_set_Minutes:
    banksel RTCCFG
    bsf	    RTCCFG, 5, B ;enable RTCWREN
    bcf	    RTCPTR1	; Clear RTCPTR1 and RTCPTR0 for seconds output
    bcf	    RTCPTR0
    movlw   01010100B
    movwf   RTCVALH, B   ; Read minutes from RTCVALH 
    return
    
RTCC_set_hours:
    banksel RTCCFG
    bsf	    RTCCFG, 5, B ;enable RTCWREN
    bcf	    RTCPTR1	; Clear RTCPTR1 and RTCPTR0 for seconds output
    bsf	    RTCPTR0
    movlw   00010000B
    movwf   RTCVALL, B   ; Read minutes from RTCVALH 
    return
    
RTCC_set_day:
    banksel RTCCFG
    bsf	    RTCCFG, 5, B ;enable RTCWREN
    bsf	    RTCPTR1	; Clear RTCPTR1 and RTCPTR0 for seconds output
    bcf	    RTCPTR0
    movlw   00000110B
    movwf   RTCVALL, B   ; Read minutes from RTCVALH 
    return
    
RTCC_set_month:
    banksel RTCCFG
    bsf	    RTCCFG, 5, B ;enable RTCWREN
    bsf	    RTCPTR1	; Clear RTCPTR1 and RTCPTR0 for seconds output
    bcf	    RTCPTR0
    movlw   00010010B
    movwf   RTCVALH, B   ; Read minutes from RTCVALH 
    return
    
    