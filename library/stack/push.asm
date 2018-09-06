;; -*- mode:pic-asm; coding: utf-8 -*-

	include "config.h"
	radix DEC
	title "Pushing and allocating stack"

	global stack_push	; Put W to INDF and advance FSR.
	global stack_alloc	; Advance FSR.
	extern do_error, stack_base, stack_init

	code
stack_push:
	movwf INDF
stack_alloc:
	incf FSR, f
	movwf INDF
	;; error checking
	movlw stack_base+STACK_SIZE-1
	subwf FSR, W
	movf INDF, W
	btfss STATUS, C
	return
	call stack_init
	movlw LOW(err_overflow)
	goto do_error

DEEPROM code
err_overflow:
	de "Overflow\0"
	end
