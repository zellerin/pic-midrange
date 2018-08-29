;;; -*- mode:pic-asm; coding:utf-8; -*-
;;; Copyright (C) 2011,2017 by Tomas Zellerin
;;;

	include "config.h"
	include "stack.h"
	title "lcd module test"
	radix DEC
	__config _INTRC_OSC_NOCLKOUT & _WDT_OFF & _MCLRE_ON

	extern uart_put_char

	org 0
init:
	movlw 7
	movwf CMCON
	movlw 0xff
	movwf GPIO
	bsf STATUS, RP0	;bank 1
	bcf TRISIO ^ 0x80, UART_PIN 	; UART out
	bcf STATUS, RP0 ;; bank 0
	extern stack_init
	call stack_init
	movlw 0x80
	movwf INDF

main_loop:
	incf INDF, f
	movf INDF, W
	bsf STATUS, RP0	;bank 1
	movwf OSCCAL
	bcf STATUS, RP0 ;; bank 0
	PUSH
	PUSH
	movlw LOW(hello_text)
	extern eeprom_print
	call eeprom_print
	extern print_octet
	POP
	call print_octet
	POP
	goto main_loop


DEEPROM code
hello_text:
	de 13, 10, "Osccal is ", 0
	end
