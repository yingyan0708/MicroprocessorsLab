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
    bcf	    RTCCFG, 5, B ;disable RTCWREN
    bsf	    RTSECSEL1	; RTSECSELx bits determine output on RTCC pin
    bcf	    RTSECSEL0	; 10 outputs the source clock, 01 outputs second count
    call    RTCC_Alarm_Setup
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

RTCC_set_seconds:
    movlw   0x55    ;first unlock key
    movwf   EECON2
    movlw   0xAA
    movwf   EECON2
    banksel RTCCFG
    bcf	    RTCCFG, 5, B ;enable RTCWREN
    bcf	    RTCPTR1	; Clear RTCPTR1 and RTCPTR0 for seconds output
    bcf	    RTCPTR0
    movlw   00000000B
    movwf   RTCVALL, B   ; Read minutes from RTCVALH 
    return
    
RTCC_set_minutes:
    movlw   0x55    ;first unlock key
    movwf   EECON2
    movlw   0xAA
    movwf   EECON2
    banksel RTCCFG
    bsf	    RTCCFG, 5, B ;enable RTCWREN
    bcf	    RTCPTR1	; Clear RTCPTR1 and RTCPTR0 for seconds output
    bcf	    RTCPTR0
    movlw   00110010B
    movwf   RTCVALH, B   ; Read minutes from RTCVALH 
    return
    
RTCC_set_hours:
    banksel RTCCFG
    bsf	    RTCCFG, 5, B ;enable RTCWREN
    bcf	    RTCPTR1	; Clear RTCPTR1 and RTCPTR0 for seconds output
    bsf	    RTCPTR0
    movlw   00010011B
    movwf   RTCVALL, B   ; set hours from RTCVALH 
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
    
    
    
RTCC_Alarm_Setup:
    banksel ALRMRPT
    banksel ALRMCFG
    movlw   11001100B ;enable alarm,enable chime to allow roll over from 00h to FFh, mask alarm to interrupt every 10 minutes 0100
    movwf   ALRMCFG, B
    movlw   0x00    
    movwf   ALRMRPT, B ;alarm will not repeat
    ;setup alarm
    bcf	    ALRMCFG, 7 ;disable alarm to change alarm values
    call    RTCC_alarm_set_seconds
    call    RTCC_alarm_set_minutes
    call    RTCC_alarm_set_hours
    call    RTCC_alarm_set_weekday
    call    RTCC_alarm_set_day
    call    RTCC_alarm_set_month
    return
    

RTCC_alarm_set_seconds:
    banksel RTCCFG
    banksel ALRMCFG
    bsf	    RTCCFG, 5, B ;enable RTCWREN
    bcf	    ALRMPTR1 ;
    bcf	    ALRMPTR0 ;
    movlw   00000000B
    movwf   RTCVALL, B   ; set seconds for ALRMVALL
    
    
RTCC_alarm_set_minutes:
    banksel RTCCFG
    banksel ALRMCFG
    bsf	    RTCCFG, 5, B ;enable RTCWREN
    bcf	    ALRMPTR1 ;
    bcf	    ALRMPTR0 ;
    movlw   00000000B
    movwf   RTCVALH, B   ; set minutes for ALRMVALH
    
RTCC_alarm_set_hours:
    banksel RTCCFG
    banksel ALRMCFG
    bsf	    RTCCFG, 5, B ;enable RTCWREN
    bcf	    ALRMPTR1 ;
    bsf	    ALRMPTR0 ;
    movlw   00010101B ;set 15:00
    movwf   RTCVALL, B   ; set hours for ALRMVALL
    
RTCC_alarm_set_weekday:
    banksel RTCCFG
    banksel ALRMCFG
    bsf	    RTCCFG, 5, B ;enable RTCWREN
    bcf	    ALRMPTR1 ;
    bsf	    ALRMPTR0 ;
    movlw   00000101B ;set weekday to friday
    movwf   RTCVALH, B   ; set weekday for ALRMVALH
    
RTCC_alarm_set_day:
    banksel RTCCFG
    banksel ALRMCFG
    bsf	    RTCCFG, 5, B ;enable RTCWREN
    bsf	    ALRMPTR1 ;
    bcf	    ALRMPTR0 ;
    movlw   00000110B ; set day to 6th
    movwf   RTCVALL, B   ; set day for ALRMVALL
    
RTCC_alarm_set_month:
    banksel RTCCFG
    banksel ALRMCFG
    bsf	    RTCCFG, 5, B ;enable RTCWREN
    bsf	    ALRMPTR1 ;set bit 1, clear bit 0
    bcf	    ALRMPTR0 
    movlw   00010010B ;set december month
    movwf   RTCVALH, B   ; set month for ALRMVALH
    
    
    
    
    