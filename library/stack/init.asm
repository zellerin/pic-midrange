;; -*- mode:pic-asm; coding: utf-8 -*-

	include "config.h"
	radix DEC
	title "Stack allocation and init"
	
	global stack_init 	; Initialize stack. Has to be called with STACK_SIZE set.
	global stack_base	; ** Where stack starts. Set by stack_init.

	
	udata_shr
stack_base:
	res STACK_SIZE

	code
stack_init:
	;; inlinable?
	movlw stack_base
	movwf FSR
	return

	end
