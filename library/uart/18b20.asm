;; -*- mode:pic-asm; coding: utf-8 -*-
        title "Dallas 18B20 interface"
        radix DEC
        include "config.h"
	include "stack.h"

	global read_temperature	; measure temperature and return it in stack, MSB on top.

	extern short_wait, do_error

;;; Expect single Dallas 18B20 with external power supply on PIN.
PIN	 equ THERMO_PIN
PIN_MASK equ 1<<PIN

;;; Dallas commands used (see datasheet for list)
CMD_CONVERT_T 		equ 0x44
CMD_READ_SCRATCHPAD 	equ 0xbe
CMD_SKIP_ROM		equ 0xcc

	code
read_temperature:
	movlw CMD_CONVERT_T
	call do_command
	call wait_for_done	; takes almost a second; maybe we can sleep a bit?
	movlw CMD_READ_SCRATCHPAD
	call do_command
	call read_byte	; read LSB
	incf FSR, F
	;; read MSB now
read_byte:
	;; read one byte and return it in INDF
	call read_nibble
read_nibble:
	call read_2bit
read_2bit:
	call read_bit
read_bit:
	call before_read_bit
	;; moving pin value to C is harder than expected
	movf PORTA, W
	andlw PIN_MASK
	addlw 256-PIN_MASK
	rrf INDF, F
	goto after_read_bit

down:
	; Pull pin down. That also means making it readable.
	bcf PORTA, PIN
	bsf STATUS, RP0
	bcf TRISA^0x80, PIN
return_to_bank0:
	bcf STATUS, RP0
	return

release:
	; Make pin readable (TRISA=1) and high impedance
	bsf STATUS, RP0
	bsf TRISA^0x80, PIN
	goto return_to_bank0

before_read_bit:
	;; Prepare for reading a bit. Waiting for some time (~50us)
	;; must follow the bit test.
	call down
	call release
	call a_return		; wait a bit
a_return:
	return

after_read_bit:
wait_90:
	movlw 30
	goto short_wait

wait_for_done:
	;; issue read sequence until it reads true.
	call before_read_bit
	btfsc PORTA, PIN
	goto after_read_bit
	call after_read_bit
	goto wait_for_done

do_command:
	;; command is in W. Do the transaction sequence, except
	;; followup data exchange.
	PUSH ; call stack_push
	call init
	movlw CMD_SKIP_ROM
	movwf INDF
	call send_cmd
	POP
send_cmd:
	; send octet in INDF
	call send_nibble
send_nibble:
	call send_2bit
send_2bit:
	call send_bit
send_bit:
	call down
	btfsc INDF, 0
	call release
	call wait_90
	rrf INDF, F
	goto release

init:
	call down
	call wait_480
	call release
	call wait_90
	movlw LOW(err_no_dallas)
	btfsc PORTA, PIN
	goto do_error
wait_480:
	movlw 160
	goto short_wait
DEEPROM code
err_no_dallas:
	de "No DS18B20\0"
        end
