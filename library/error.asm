;; -*- mode:pic-asm; coding: utf-8 -*-
	include "config.h"
	title "Error handling"
	radix DEC

	udata_shr
errcode	res 1

	global do_error
	extern eeprom_print
	code
do_error:
	movwf errcode
	movlw LOW(error_text)
	call eeprom_print
	movf errcode, W
	call eeprom_print
	clrf INTCON
	sleep
	goto $-1

DEEPROM	code
error_text:
	de "\nError: \0"
	end
