	list p=16F630,t=ON,c=132,n=80
	title "Stack ops"
	radix DEC
	include "p16f630.inc"

	extern do_error
	global stack_init, stack_push,stack_pop, stack_save, stack_restore

	global stack_saved, stack

STACK_SIZE: equ 0x20
	udata_shr
stack_saved:
	res 1
stack:
	res STACK_SIZE

	code
stack_init:
	;; inlinable?
	movlw stack
	movwf FSR
;	fall through

stack_save:
	movf FSR, W
	movwf stack_saved
	return

stack_restore:
	movf stack_saved, W
	movwf FSR
	return

stack_push:
	movwf INDF
	incf FSR, f
	;; error checking
	movlw stack+STACK_SIZE-1
	subwf FSR, W
	btfss STATUS, C
	goto stack_save
	call stack_init
	movlw LOW(err_overflow)
	goto do_error

stack_pop:
	decf FSR, f
	;; error checking
	movlw stack
	subwf FSR, w
	movf INDF, w
	btfsc STATUS, C
	goto stack_save
	call stack_init
	movlw LOW(err_underflow)
	goto do_error


DEEPROM code
err_overflow:
	de "Overflow\0"
err_underflow:
	de "Underflow\0"
	end
