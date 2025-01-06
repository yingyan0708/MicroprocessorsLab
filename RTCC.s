#include <xc.inc>
    
global  RTCC_Setup, RTCC_Get_Seconds, RTCC_Get_Minutes, RTCC_Get_Hours, RTCC_Get_Weekday, RTCC_Get_Day, RTCC_Get_Month, RTCC_Get_Year, RTCC_alarm_get_minutes
extrn	alarm_mask
    
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
    call    RTCC_set_minutes
    call    RTCC_set_hours
    call    RTCC_Alarm_Setup
    bcf	    RTCCFG, 5, B ;disable RTCWREN
    bsf	    RTSECSEL1	; RTSECSELx bits determine output on RTCC pin
    bcf	    RTSECSEL0	; 10 outputs the source clock, 01 outputs second count
    movlb   0		; reset BSR to 0
    return

RTCC_Get_Seconds:	; Reads and stores seconds value in RTCC_Seconds
			; Also returns the value in W register
    banksel RTCCFG	; RTCC SFRs are not in access ram
    ;read second and minute(RTCPTR = 00)
    bcf	   RTCPTR1	; Clear RTCPTR1 and RTCPTR0 for seconds output
    bcf	    RTCPTR0
    movf    RTCVALL,W,B ;Read second from RTCVALL
    ;movwf   RTCC_seconds, A ; Store value in RTCC_Seconds variable space
    ;movf    RTCVALH, W, B   ; Read minutes from RTCVALH 
    ;movwf   RTCC_minutes, A	; Store value in RTCC_Minutes variable space
    movlb   0		; reset BSR to 0
    return

RTCC_Get_Minutes:	; Reads and stores minute value in RTCC_minutes
			; Also returns the value in W register
    banksel RTCCFG	; RTCC SFRs are not in access ram
    bcf	    RTCPTR1	; Clear RTCPTR1 and RTCPTR0 for minute output
    bcf	    RTCPTR0
    movf    RTCVALH, W, B   ; Read minutes from RTCVALH 
    movlb   0		; reset BSR to 0
    return
    
RTCC_Get_Hours:	; Reads and stores hours value in RTCC_hours
			; Also returns the value in W register
    banksel RTCCFG	; RTCC SFRs are not in access ram
    bcf	    RTCPTR1	; Clear RTCPTR1 and set RTCPTR0 for hours output
    bsf	    RTCPTR0
    movf    RTCVALL, W, B   ; Read hours from RTCVALL
    movlb   0		; reset BSR to 0
    return
   
    
RTCC_Get_Weekday:	; Reads and stores weekday
			; Also returns the value in W register
    banksel RTCCFG	; RTCC SFRs are not in access ram
    bcf	    RTCPTR1	; Clear RTCPTR1 and set RTCPTR0 for weekday output
    bsf	    RTCPTR0
    movf    RTCVALH, W, B   ; Read weekday from RTCVALH 
    movlb   0		; reset BSR to 0
    return

RTCC_Get_Day:	; Reads and stores day value 
			; Also returns the value in W register
    banksel RTCCFG	; RTCC SFRs are not in access ram
    bsf	    RTCPTR1	; set RTCPTR1 and clear RTCPTR0 for day output
    bcf	    RTCPTR0
    movf    RTCVALL, W, B   ; Read day from RTCVALL
    movlb   0		; reset BSR to 0
    return
    
RTCC_Get_Month:	; Reads and stores month value 
			; Also returns the value in W register
    banksel RTCCFG	; RTCC SFRs are not in access ram
    bsf	    RTCPTR1	; set RTCPTR1 and clear RTCPTR0 for month output
    bcf	    RTCPTR0
    movf    RTCVALH, W, B   ; Read month from RTCVALH 
    movlb   0		; reset BSR to 0
    return

RTCC_Get_Year:	; Reads and stores year value
			; Also returns the value in W register
    banksel RTCCFG	; RTCC SFRs are not in access ram
    bsf	    RTCPTR1	; set RTCPTR1 and set RTCPTR0 for year output
    bsf	    RTCPTR0
    movf    RTCVALL, W, B   ; Read year from RTCVALL
    movlb   0		; reset BSR to 0
    return

;set

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
    movwf   RTCVALL, B   ; rewrite second register 
    return
    
RTCC_set_minutes:
    movlw   0x55    ;first unlock key
    movwf   EECON2
    movlw   0xAA
    movwf   EECON2
    banksel RTCCFG
    bsf	    RTCCFG, 5, B ;enable RTCWREN
    bcf	    RTCPTR1	; Clear RTCPTR1 and RTCPTR0 for minute output
    bcf	    RTCPTR0
    movlw   00010100B
    movwf   RTCVALH, B   ; rewrite minute
    return
    
RTCC_set_hours:
    banksel RTCCFG
    bsf	    RTCCFG, 5, B ;enable RTCWREN
    bcf	    RTCPTR1	; Clear RTCPTR1 and set RTCPTR0 for hour
    bsf	    RTCPTR0
    movlw   00010011B
    movwf   RTCVALL, B   ; set hours from RTCVALL
    return
    
RTCC_set_day:
    banksel RTCCFG
    bsf	    RTCCFG, 5, B ;enable RTCWREN
    bsf	    RTCPTR1	; set RTCPTR1 and clear RTCPTR0 for day value
    bcf	    RTCPTR0
    movlw   00010011B
    movwf   RTCVALL, B   ; rewrite day in RTCVALL register
    return
    
RTCC_set_weekday:
    movlw   0x55    ;first unlock key
    movwf   EECON2
    movlw   0xAA
    movwf   EECON2
    banksel RTCCFG
    bsf	    RTCCFG, 5, B ;enable RTCWREN
    bcf	    RTCPTR1	; Clear RTCPTR1 and set RTCPTR0 for weekday
    bsf	    RTCPTR0
    movlw   00000101B
    movwf   RTCVALH, B   ; rewrite weekday
    return
    
RTCC_set_month:
    banksel RTCCFG
    bsf	    RTCCFG, 5, B ;enable RTCWREN
    bsf	    RTCPTR1	; set RTCPTR1 and clear RTCPTR0 for month 
    bcf	    RTCPTR0
    movlw   00010010B
    movwf   RTCVALH, B   ; rewrite month register
    return
    
RTCC_set_year:
    banksel RTCCFG
    bsf	    RTCCFG, 5, B ;enable RTCWREN
    bsf	    RTCPTR1	; set RTCPTR1 and set RTCPTR0 for year
    bsf	    RTCPTR0
    movlw   00100100B
    movwf   RTCVALL, B   ; rewrite year
    return
    
    
;setting alarm for interrupt    
RTCC_Alarm_Setup:
    banksel ALRMRPT
    banksel ALRMCFG
    ;movlw   11000100B ;enable alarm,enable chime to allow roll over from 00h to FFh, mask alarm to interrupt every 10 minutes 0100
    movf    alarm_mask, W, A
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
    bsf	    ALRMCFG, 7
    return
    

RTCC_alarm_set_seconds: ;set the intial alarm - seconds
    ;unlock RTCC
    movlw   0x55    ;first unlock key
    movwf   EECON2
    movlw   0xAA    ;second unlock key
    movwf   EECON2
    banksel RTCCFG
    banksel ALRMCFG
    bsf	    RTCCFG, 5, B ;enable RTCWREN to write alarm register
    bcf	    ALRMPTR1 ;clear ALRMPTR1 and 0 for alarm minutes and seconds
    bcf	    ALRMPTR0 
    movlw   00000000B
    movwf   ALRMVALL, B   ; set seconds to 0
    return
    
RTCC_alarm_set_minutes:
    movlw   0x55    ;first unlock key
    movwf   EECON2
    movlw   0xAA
    movwf   EECON2
    banksel RTCCFG
    banksel ALRMCFG
    bcf	    RTCCFG, 5, B ;enable RTCWREN
    bcf	    ALRMPTR1 ;
    bcf	    ALRMPTR0 ;
    movlw   00100010B
    movwf   ALRMVALH, B   ; set minutes for ALRMVALH
    return

RTCC_alarm_get_minutes:
    banksel RTCCFG
    banksel ALRMCFG
    bcf	    ALRMPTR1 ;
    bcf	    ALRMPTR0 ;
    movf    ALRMVALH, W, B   ; Read minutes from RTCVALH 
    movlb   0		; reset BSR to 0
    return
    
RTCC_alarm_set_hours:
    banksel RTCCFG
    banksel ALRMCFG
    bsf	    RTCCFG, 5, B ;enable RTCWREN
    bcf	    ALRMPTR1 ;
    bsf	    ALRMPTR0 ;
    movlw   00010000B 
    movwf   ALRMVALL, B   ; set hours for ALRMVALL
    return
    
RTCC_alarm_set_weekday:
    banksel RTCCFG
    banksel ALRMCFG
    bsf	    RTCCFG, 5, B ;enable RTCWREN
    bcf	    ALRMPTR1 ;
    bsf	    ALRMPTR0 ;
    movlw   00001001B 
    movwf   ALRMVALH, B   ; set weekday for ALRMVALH
    return
    
RTCC_alarm_set_day:
    banksel RTCCFG
    banksel ALRMCFG
    bsf	    RTCCFG, 5, B ;enable RTCWREN
    bsf	    ALRMPTR1 ;
    bcf	    ALRMPTR0 ;
    movlw   00010011B ; set day to 6th
    movwf   ALRMVALL, B   ; set day for ALRMVALL
    return
    
RTCC_alarm_set_month:
    banksel RTCCFG
    banksel ALRMCFG
    bsf	    RTCCFG, 5, B ;enable RTCWREN
    bsf	    ALRMPTR1 ;set bit 1, clear bit 0
    bcf	    ALRMPTR0 
    movlw   00010010B ;set december month
    movwf   ALRMVALH, B   ; set month for ALRMVALH
    return
    
    
    
    
