;;; -*- mode:pic-asm -*-
        list p=16F630,t=ON,c=132,n=80
        title "lcd module test"
        radix DEC
        include "p16f630.inc"

	global eeprom_at, eeprom_getchar
	code
;;;

eeprom_at: ; E -> [E];  EEADR = E+1
        ;; Read content of eeprom from address.
	;; Next eeprom reads with getchar will follow
        bsf     STATUS, RP0 ;; bank 1
        movwf   EEADR
eeprom_getchar:	; ? -> [EEADR] ; increase EEADR
	;; Read next eeprom octet and advance.
        bsf     STATUS, RP0 ;; bank 1
        bsf     EECON1, 0
        incf    EEADR, f
        movf    EEDAT, w
        bcf     STATUS, RP0 ;; bank 0
	return
	end
