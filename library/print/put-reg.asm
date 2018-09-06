;; -*- mode:pic-asm; coding: utf-8 -*-
	include "config.h"
	title "Octet to ascii conversion"
	radix DEC
	include "stack.h"

	global print_octet	; Print byte in INDF using eeprom_put_fn. Can change INDF.
	extern eeprom_put_fn

	code
print_octet:
	swapf INDF, W
	ALLOC
        call print_nibble
	POP
print_nibble:
        ;; Convert nibble to ascii and put to the screen
        andlw   0xf
        addlw   0xf6
	btfsc   STATUS, C
        addlw   0x7
        addlw   0x3a
	goto eeprom_put_fn
	end
