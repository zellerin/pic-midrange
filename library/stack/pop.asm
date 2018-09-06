;; -*- mode:pic-asm; coding: utf-8 -*-

	include "config.h"
	radix DEC
	title "Stack ops"

	global stack_pop 	; Decrease FSR and put INDF to W.
	extern do_error, stack_base, stack_init

	code

stack_pop:
	decf FSR, f
	;; prepare error checking
	movlw stack_base
	subwf FSR, w
	;; read popped data
	movf INDF, w
	;; do error checking
	btfsc STATUS, C
	return
	call stack_init
	movlw LOW(err_underflow)
	goto do_error

DEEPROM code
err_underflow:
	de "Underflow\0"
	end
