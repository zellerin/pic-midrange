	include "config.h"
	radix DEC
	title "Stack ops"

;;; Implement stack on midrange pics.
;;; Top of stack is in INDF (address in FSR).
;;; Initially, stack size is 20 octets.
	global stack_pop
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
