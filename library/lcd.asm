;; -*- mode:pic-asm; coding: utf-8 -*-
        include "config.h"
        title "lcd module low-level communication"
        radix DEC

	extern mswait
        udata_shr
scratch:
        ;; used by nibble rotating things
        res .1
nibble:
        ;; parameter for nibble putting code
        res .1

        code
;;; Putting things to LCD
	global eeprom_put_fn
eeprom_put_fn:			; callback for print_from_prom
put:				; used internally to send commands
        ;; send a char or command in W to screen in two 4bit parts
        movwf   nibble
        movlw   0x3
        call    mswait
        call    push_high_nibble
	goto    push_high_nibble

	global emit_w_nibble
emit_w_nibble:
	movwf   nibble
push_high_nibble:
        ;; Input: nibble = [ A B ] scratch = [ D (4bit) F E(3 bit) ]
        ;;      carry C
        ;; Output:
        ;;    nibble = [ B C rev E ] scratch = [ rev A D ] W = [ 1 A ]
        ;; Put reversed high nibble of  nibble register to low nibble of W
        ;; through high nibble of scratch
        ;; and push low nibble of 0x23 to its high nibble
        ;; n.b. initializing scratch with 0x10 to would work too, but
        ;; same instruction count as andlw/iorlw
        call rotate_2bit
        call rotate_2bit
        swapf scratch, w
        andlw   0xf
        iorlw   (1<<ENABLE)
        movwf   PORTC
        bcf     PORTC, ENABLE
        return
rotate_2bit:
        call rotate_bit
rotate_bit:
        rlf     nibble, f
        rrf     scratch, f
        return

;;; Simple commands
        global send_command, slow_shift_right
slow_shift_right:
        movlw   0
        call    mswait
        movlw   0x1c
send_command:
        bcf     PORTA, RS
        goto    put

;;; Multi-octet commands
	global print_text_from_prom
	extern eeprom_at, eeprom_getchar, eeprom_print
print_text_from_prom:
        bsf  PORTA, RS
	goto eeprom_print
        end
