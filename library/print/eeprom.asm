;;; -*- mode:pic-asm -*-

        include "config.h"
        title "Print string using function."
        radix DEC

	extern eeprom_at
	extern eeprom_getchar
	global eeprom_print 	; Print text in eeprom indexed by W using eeprom_put_fn.
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

	end
