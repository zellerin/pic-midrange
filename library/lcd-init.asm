;;;  -*- mode:pic-asm -*-
        include "config.h"
        title "lcd module test"
        radix DEC

	global init_lcd
	extern put_reg_indf, mswait
	extern short_wait, eeprom_print
	extern emit_w_nibble

	code
wait_and_reset:
        call mswait
send_reset:
        movlw   0x30            ; set 8bit
        goto emit_w_nibble


init_lcd:
        bcf     PORTA, RS           ; commands follow
        clrf    PORTC
        movlw   0x14
        call    wait_and_reset
        movlw   0x6
        call    wait_and_reset
        movlw   0x1f
        call    short_wait
        call    send_reset
        movlw   0x3
        call    mswait
        movlw   0x20            ; set 4bit
        call emit_w_nibble
        movlw   LOW(initcode)
        goto eeprom_print

DEEPROM code
initcode:
        de 0x28                 ; 4bit 2 lines
        de 8                    ; display off, no cursor, no blink
        de 1                    ; clear
        de 6                    ; increment, dont shift display
        de 0xc                  ; display on, no cursor, no blink
        de 0

	end
