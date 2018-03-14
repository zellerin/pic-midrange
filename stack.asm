	list p=16F630,t=ON,c=132,n=80
	title "Stack ops"
	radix DEC
	include "p16f630.inc"

;;; Implement stack on midrange pics.
;;; Top of stack is in INDF (address in FSR).
;;; Initially, stack size is 20 octets.
	extern do_error
	global stack_init, stack_push,stack_pop

STACK_SIZE: equ 0x20
	udata_shr
stack:
	res STACK_SIZE

	code
stack_init:
	;; inlinable?
	movlw stack
	movwf FSR
	return

stack_push:
	movwf INDF
	incf FSR, f
	;; error checking
	movlw stack+STACK_SIZE-1
	subwf FSR, W
	btfss STATUS, C
	return
	call stack_init
	movlw LOW(err_overflow)
	goto do_error

stack_pop:
	decf FSR, f
	;; prepare error checking
	movlw stack
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
err_overflow:
	de "Overflow\0"
err_underflow:
	de "Underflow\0"
	end
