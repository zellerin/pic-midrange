;; -*- mode:pic-asm; coding: utf-8 -*-

	include "config.h"
	include "stack.h"
	title "Error handling"
	radix DEC

	global do_error
	extern eeprom_print
	code
do_error:
	call stack_push
	movlw LOW(error_text)
	call eeprom_print
	call stack_pop
	call eeprom_print
	clrf INTCON
	sleep
	goto $-1

DEEPROM	code
error_text:
	de "\nError: \0"
	end
