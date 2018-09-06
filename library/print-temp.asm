;; -*- mode:pic-asm; coding: utf-8 -*-
	title "Print temperature"
	radix DEC
	include "config.h"
	include "stack.h"
	include "print.h"

	extern read_temperature
	global print_temperature ; Read temperature and print it out using eeprom_put_fn.
	
	code
print_temperature:
	call read_temperature
	ALLOC
	movlw LOW(temperature)
	call eeprom_print
	POP
	call print_octet
	POP
	goto print_octet
	
DEEPROM	code
temperature:
	de "\nTemp: \0"
	end
