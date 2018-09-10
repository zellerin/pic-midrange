;;; -*- mode:pic-asm; coding:utf-8; -*-
;;; Copyright (C) 2011,2017 by Tomas Zellerin
;;;
;;; Drive LCD with microchip pic16f630
;;; Digged out from my archives
;;;

	include "config.h"
	title "lcd module test"
	radix DEC
	include "stack.h"
	__config _INTRC_OSC_NOCLKOUT & _WDT_OFF & _MCLRE_ON

	extern init_lcd, print_text_from_prom, send_command, slow_shift_right, put_reg
	extern put_char
	extern put_reg_indf, mswait

	extern stack_init

	extern read_temperature

	code
	org 0

	movlw 7
	movwf CMCON
	clrf PORTA
	clrf PORTC
;;; Pull-up is sufficient for the 1wire communication:
;;; clear bit 7 of OPTION_REG (RAPU), set WPUA pin 5
;;; current is 50-250-500 uA at 5V
	bsf STATUS, RP0	;bank 1
	bcf OPTION_REG, 7 	; RAPU
	bsf WPUA, 5		; pull up
	movlw 0x3b 	; pin2 is out, rest in
	movwf TRISA ^ 0x80
	clrf TRISC ^ 0x80	; all out
	bcf STATUS, RP0 ;; bank 0
	call stack_init

main_loop:
	call init_lcd
        bsf  PORTA, RS

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
temperature:
	de "Temp: \0"
	end
