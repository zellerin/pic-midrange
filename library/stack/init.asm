;; -*- mode:pic-asm; coding: utf-8 -*-
	title "Stack allocation and init"
	radix DEC
	include "config.h"
	
	global stack_init, stack_base

	
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
