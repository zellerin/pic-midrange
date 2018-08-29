;; -*- mode:pic-asm; coding: utf-8 -*-
	include "config.h" 

	title "Print errors on LCD"
	radix DEC
	global do_error
	extern init_lcd, print_text_from_prom, send_command
	
	udata_shr
errcode:
	res 1

	code
	
do_error:
	movwf errcode
	call init_lcd
	movlw LOW(error_text)
	call print_text_from_prom
	movlw 0xc0 		; set ddram address = 0x40
	call send_command ; i.e., move to 2nd row
	movf errcode,W
	call print_text_from_prom
	clrf INTCON
	sleep
	goto $-1


DEEPROM	code
error_text:
	de "Error: \0"
	end
