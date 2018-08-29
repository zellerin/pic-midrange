;;; -*- mode:pic-asm; coding:utf-8; -*-
;;; Copyright (C) 2011,2017,2018 by Tomas Zellerin
;;;
;;; Measure temperature and report in on uart.

	radix DEC
	include "config.h"
	title "lcd module test"
	include "stack.h"

	__config 0x1ff &(_INTRC_OSC_NOCLKOUT & _WDT_OFF & _MCLRE_OFF)

	extern eeprom_print
	extern mswait

	extern stack_init


	code
	org 0
	goto init
;;; complete start
init:
	movlw 7
	movwf CMCON
	movlw 0xFF
	movwf GPIO
	call stack_init
;;; Pull-up is sufficient for the 1wire communication:
;;; clear bit 7 of OPTION_REG (RAPU), set WPUA pin 5
;;; current is 50-250-500 uA at 5V
	bsf STATUS, RP0	;bank 1
	call 0x3ff
	movwf OSCCAL
	clrf ANSEL
	bcf OPTION_REG ^ 0x80, NOT_GPPU ; enable pull ups in general
	movlw 1<<THERMO_PIN
	movwf WPU ^ 0x80
	bcf TRISIO ^ 0x80, UART_PIN ; other are in, thermo week pulled up
	bcf TRISIO ^ 0x80, 1 ; power thermometer
	bcf STATUS, RP0 ;; bank 0

	movlw LOW(hello_text)
	call eeprom_print

main_loop:
	extern print_temperature
	call print_temperature
	call long_wait
	goto main_loop

long_wait:
	call $+1
	call $+1
	movlw 0x0
	goto mswait

DEEPROM code
hello_text:
	de 13, 10, "(starting)", 0


	end
