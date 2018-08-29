;; -*- mode:pic-asm; coding: utf-8 -*-
	title "Print temperature"
	radix DEC
	include "config.h"
	include "stack.h"

	extern print_octet, eeprom_print
	extern read_temperature
	global print_temperature
	
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
