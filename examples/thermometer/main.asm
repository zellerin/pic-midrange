;;; -*- mode:pic-asm; coding:utf-8; -*-
;;; Copyright (C) 2011,2017,2018 by Tomas Zellerin
;;;
;;; Measure temperature and report in on uart.

	radix DEC
	include "config.h"
	title "lcd module test"
	include "stack.h"
	include "print.h"
	include "18b20.h"

	__config 0x1ff &(_INTRC_OSC_NOCLKOUT & _WDT_ON & _MCLRE_OFF)
	extern mswait

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
	; incidentally, it also sets prescaler to WDT and 1:128
	movlw 1<<THERMO_PIN
	movwf WPU ^ 0x80
	bcf TRISIO ^ 0x80, UART_PIN ; other are in, thermo week pulled up
	bcf TRISIO ^ 0x80, 1 ; power thermometer
	bcf STATUS, RP0 ;; bank 0

	movlw LOW(hello_text)

	global main_loop	; for gpsim break
main_loop:
	call print_temperature
	sleep
	goto main_loop

DEEPROM code
hello_text:
	de 13, 10, "(starting)", 0


	end
