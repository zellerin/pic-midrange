;; -*- mode:pic-asm; coding: utf-8 -*-
	list p=16F630
	title "57600 bitbang uart"
	radix DEC
	include "p16f630.inc"
	global uart_put_char

UART_PIN:	equ 4
UART_PIN_MASK:	equ 1 << UART_PIN

	udata_shr

	code
uart_put_char:
	;; send out octet in INDF. Destroys W.
	;; assume port initialized
	movf PORTA, W
	bcf STATUS, C
	call put_carry 		; start bit
	call rot_put_bit		;1
	call rot_put_bit		;2
	call rot_put_bit		;3
	call rot_put_bit		;4
	call rot_put_bit		;5
	call rot_put_bit		;6
	call rot_put_bit		;7
	call rot_put_bit		;8
	;; go high state
	rrf INDF, F
	bsf STATUS, C		; stop bit
	call put_carry
	goto a_ret

rot_put_bit:
	;; this should give 16us pulses (including call and return), which is 57k6 baud.
	;; 115k2 would need shaving off a us.
	rrf INDF, F		; call+1=3
	;; the nop should be here, so that it matches stop bit
	;; code. However, the gpsim does not like that, so I moved it below
	;nop			; 4
put_carry:
	andlw 0xff^UART_PIN_MASK ;5
	btfsc STATUS, C		 ;6
	iorlw UART_PIN_MASK	 ;7
	movwf PORTA		 ;8 - here change goes
	nop			 ; moved from up - see above
a_ret:
	call $+1		; 10
	nop			; 11,14
	return			; 13,16

	end
