;;; -*- mode:pic-asm; coding:utf-8; -*-
;;; Copyright (C) 2011,2017 by Tomas Zellerin
;;;
;;; Drive LCD with microchip pic16f630
;;; Digged out from my archives
;;;

	list p=16F630,t=ON,c=132,n=80
	title "lcd module test"
	radix DEC
	include "p16f630.inc"
	__config _INTRC_OSC_NOCLKOUT & _WDT_OFF & _MCLRE_ON

	extern init_lcd, print_text_from_prom, send_command, slow_shift_right, put_reg
	extern put_char
	extern put_reg_indf, mswait

	extern stack_init,stack_push, stack_pop, stack_save,stack_restore, stack_saved

	extern read_temperature
	
	global do_error	
	udata_shr
intr_w:	res 1
intr_status:
	res 1
intr_fsr:
	res 1
errcode:
	res 1
temp_byte:
	res 1
	
	code
	org 0
	goto init
;;; interrupt code
	org 4
	movwf intr_w
	movf STATUS, w
	movwf intr_status

	movf intr_status, w
	movwf STATUS
	swapf intr_w, f
	swapf intr_w, w
	retfie
;;; complete start
init:
	movlw 7
	movwf CMCON
;	clrf TMR1H
;	clrf TMR1L
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
;	movlw 0x30
;	movwf IOCA
	bcf STATUS, RP0 ;; bank 0
	;; Count internal clock. Interrupt will use it.
;	movlw (1<<TMR1ON) | (1<<NOT_T1SYNC)
;	movwf T1CON  ; Clock on gate
;	movlw (1<<GIE) | (1<<RAIE)
;	movwf INTCON
	call stack_init
	
main_loop:
	call init_lcd	
	
	call read_temperature
	movlw LOW(temperature)
	call print_text_from_prom
	call put_reg_indf
	call stack_pop
	call put_reg_indf
	call long_wait
	goto main_loop
	
long_wait:
	call $+1
	call $+1
	movlw 0x0
	goto mswait

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
	
DEEPROM code
temperature:
	de "Temp: \0"
error_text:
	de "Error: \0"
	end
