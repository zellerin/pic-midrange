;;; -*- mode:pic-asm; coding:utf-8; -*-
;;; Copyright (C) 2011,2017 by Tomas Zellerin
;;;
;;; Drive LCD with microchip pic16f630
;;; Digged out from my archives
;;;

	list p=12F675,t=ON,c=132,n=80
	title "lcd module test"
	radix DEC
	include "p12f675.inc"
	__config _INTRC_OSC_NOCLKOUT & _WDT_OFF & _MCLRE_ON

	extern uart_put_char

	org 0
init:
	movlw 7
	movwf CMCON
;	clrf TMR1H
;	clrf TMR1L
	movlw 0xff
	movwf GPIO
;;; Pull-up is sufficient for the 1wire communication:
;;; clear bit 7 of OPTION_REG (RAPU), set WPUA pin 5
;;; current is 50-250-500 uA at 5V
	bsf STATUS, RP0	;bank 1
	clrf TRISIO ^ 0x80 	; all out
	call 0x3ff
	movwf OSCCAL
	bcf STATUS, RP0 ;; bank 0
	;; FSR and INDF
	movlw 0x20		
	movwf FSR
main_loop:
	movlw LOW(hello_text)
	extern eeprom_print
	call eeprom_print
	goto main_loop
	global eeprom_put_fn
eeprom_put_fn:
	movwf INDF
	goto uart_put_char

DEEPROM code
hello_text:
	de "Hello", 13, 10, 0

	end
