;; -*- mode:pic-asm; coding: utf-8 -*-
	title "115k bitbang uart"
	radix DEC
	include "config.h"
	global uart_put_char

UART_PIN_MASK:	equ 1 << UART_PIN

	udata_shr

	code
uart_put_char:
	;; send out octet in INDF. Destroys W.
	;; assume port initialized
	movf PORTA, W
	andlw 0xff^UART_PIN_MASK
	movwf PORTA		; low
	rrf INDF, F		; low+1
	nop
	call rot_put_2bit		;last+4
	call rot_put_2bit		;
	call rot_put_2bit		;
	call rot_put_2bit		;last+4
	iorlw UART_PIN_MASK	 ;+3
	call ret		 ;+5
save_porta:
	movwf PORTA		; low
ret:	return

rot_put_2bit:
	;; this should give 8us pulses (including call and return), which is 115k2 Bd.
	andlw 0xff^UART_PIN_MASK ;last+5
	btfsc STATUS, C		 ;6
	iorlw UART_PIN_MASK	 ;7
	movwf PORTA		 ;8 - here change goes
	rrf INDF, F		; +1
	andlw 0xff^UART_PIN_MASK ;+2
	btfsc STATUS, C		 ;+3
	iorlw UART_PIN_MASK	 ;+4
	rrf INDF, F		; +5 - here we get missing us by swap with mowf that follows
	goto save_porta 

	end
