	include "config.h"
	radix DEC
	title "Stack ops"

;;; Implement stack on midrange pics.
;;; Top of stack is in INDF (address in FSR).
;;; Initially, stack size is 20 octets.
	global stack_push, stack_alloc
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
