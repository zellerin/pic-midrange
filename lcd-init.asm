        list p=16F630,t=ON,c=132,n=80
        title "lcd module test"
        radix DEC
        include "p16f630.inc"

	global init_lcd
	extern put_reg_indf, wait_1
	extern short_wait, print_from_prom
	extern emit_w_nibble

RS:	equ 2			; on porta

	code
wait_and_reset:
        call wait_1
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
        call    wait_1
        movlw   0x20            ; set 4bit
        call emit_w_nibble
        movlw   LOW(initcode)
        goto print_from_prom


DEEPROM code
initcode:
        de 0x28                 ; 4bit 2 lines
        de 8                    ; display off, no cursor, no blink
        de 1                    ; clear
        de 6                    ; increment, dont shift display
        de 0xc                  ; display on, no cursor, no blink
        de 0

	end
