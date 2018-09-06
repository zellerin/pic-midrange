;;; -*- mode:pic-asm -*-
        include "config.h"
        title "lcd module test"
        radix DEC

	global eeprom_at, eeprom_getchar, eeprom_print
	extern eeprom_put_fn
	code
;;;
eeprom_print:
        ;; Call eeprom_put_fn for bytes from prom until 0 is seen
	call eeprom_at
print_next:
        btfsc STATUS, Z
        return
        call eeprom_put_fn
	call eeprom_getchar
        goto print_next

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
