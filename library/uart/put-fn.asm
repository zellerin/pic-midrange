;; -*- mode:pic-asm; coding: utf-8 -*-
	title "Function to print to uart."
	radix DEC
	include "config.h"
	
	global eeprom_put_fn
	extern uart_put_char

	code
eeprom_put_fn:
	movwf INDF
	goto uart_put_char

	
	end
