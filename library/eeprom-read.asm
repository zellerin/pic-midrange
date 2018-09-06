;;; -*- mode:pic-asm -*-
	
        include "config.h"
        title "lcd module test"
        radix DEC

	global eeprom_at	; Read from EEPROM[INDF] to INDF and remeber where to read from.
	global eeprom_getchar	; Read next octet from eeprom
	code

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
