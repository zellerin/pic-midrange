  org 0
  goto    init
;;; interrupt
  org 4
  btfss   0x0b, 0x6	; INTCON.PEIE
  retfie
  movlb   0x0e
  btfsc   0x19, 0x4	; PIE3.TXIE
  btfss   0x0f, 0x4	; PIR3.TXIF
  goto    int_rc
  call    transmit_isr
  retfie
int_rc:
  btfsc   0x19, 0x5	; PIE3.RCIE
  btfss   0x0f, 0x5	; PIR3.RCIF
  retfie
  call    isr_receive
int_end
  retfie

rxtail equ 0x7a
rxcount equ 0x39
rxhead equ 0x7b

buf2size equ 0x45

init:
  clrf    rxtail
  clrf    rxhead
  clrf    0x7c
;;; FSR0 = 0x20
  movlw   0x20
  movwf   0x04
  movlw   0x00
  movwf   0x05
  movlw   0x1b
  call    system_init_2
  movlb   0x00
  goto    main
eusart_init:
  movlb   0x0e
  bcf     0x19, 0x5	; pie3 - rcie
  movlb   0x0e
  bcf     0x19, 0x4	; pie3 - 0719
;;; USART
  movlw   0x08
  movlb   0x02
  movwf   0x1f 	; baud1con
  movlw   0x90
  movwf   0x1d	; rcsta
  movlw   0x24
  movwf   0x1e	; txsta
  movlw   0x19
  movwf   0x1b	; spbrgl
  clrf    0x1c	; spbrgh
  movlb   0x00
  clrf    0x38	; txhead
  clrf    0x7c	; txtail
  clrf    0x3a	; buffer size remaining
  movlw   0x08
  movwf   0x73
  movwf   buf2size
  clrf    rxhead	; rxhead
  clrf    rxtail	; rxtail
  clrf    rxcount	; rxcount
  movlb   0x0e
  bsf     0x19, 0x5	; PIE3.RCIE
	return

isr_receive:
  movf    rxhead, 0x0
  addlw   0x20
  movwf   0x06
  clrf    0x07  ; FSR1 = 0x2*rxhead
  clrf    0x01  ; INDF1
  movlb   0x02
  btfss   0x1d, 0x2 ; RCSTA.FERR
  goto    old_08f
  bsf     0x01, 0x1 ; INDF1
  call frame_error_handle
old_08f:
  movlb   0x02
  btfss   0x1d, 0x1 ; RCSTA.OERR
  goto    old_a0
  bsf     0x01, 0x2 ; indf
  call overrun_handler
old_a0:
  movf    0x01, 0x0
  btfsc   0x03, 0x2   ; zero?
  goto    old_b0
  call    hw_receive
old_b0:
  goto    hw_receive

;;; receive
do_receive:
  clrf    0x72
old_b8
  movlb   0x00
  movf    rxcount, 0x0		; count
  btfsc   0x03, 0x2		; flag of being done
  goto    old_b8
  movf    rxtail, 0x0		; indf = rxtail + 20
  addlw   0x20			;
  movwf   0x06
  clrf    0x07
  movf    0x01, 0x0		; value
  movwf   0x71
  movf    0x71, 0x0
  movwf   0x38
  movf    rxtail, 0x0
  addlw   0x28
  movwf   0x06
  clrf    0x07
  movf    0x01, 0x0
  movwf   0x71
  movf    0x71, 0x0
  movwf   0x72
  movlw   0x01
  movwf   0x71
  movf    0x71, 0x0
  addwf   rxtail, 0x1
  movlw   0x08
  subwf   rxtail, 0x0
  btfsc   0x03, 0x0
  clrf    rxtail
  movlb   0x0e
  bcf     0x19, 0x5
  movlw   0x01
  movlb   0x00
  subwf   rxcount, 0x1
  movlb   0x0e
  bsf     0x19, 0x5
  movf    0x72, 0x0
  return
main:
  call    system_init
  bsf     0x0b, 0x7 	; intcon
  bsf     0x0b, 0x6	; intcon
  movlw   low(receive_and_display)
  movwf   0x04
  movlw   high(receive_and_display)
  movwf   0x05
  call    puts
main_loop
  call    do_receive
  movwf   0x79
  movf    0x79, 0x0
  movlb   0x00
  call    write_char
  movlw   0x0d
  call    write_char
  movlw   0x0a
  call    write_char
  movlw   0x4f
  call    write_char
  movlw   0x6b
  call    write_char
  movlw   0x3e
  call    write_char
  movlb   0x00
  movf    0x46, 0x0
  movwf   0x16
  goto    main_loop
  goto    main_loop
  goto    init
write_char:
  movwf   0x72
write_char_2
  movlb   0x00
  movf    buf2size, 0x0
  btfsc   0x03, 0x2	; while buffer remaining
  goto    write_char_2
  movlb   0x0e
  btfsc   0x19, 0x4	; PIE3.TXIE
  goto    old_126
  movf    0x72, 0x0
  movlb   0x02
  movwf   0x1a
  goto    old_13f
old_126:
  bcf     0x19, 0x4
  movf    0x72, 0x0
  movwf   0x71
  movf    0x7c, 0x0
  addlw   0x30
  movwf   0x06
  clrf    0x07
  movf    0x71, 0x0
  movwf   0x01
  movlw   0x01
  movwf   0x71
  movf    0x71, 0x0
  addwf   0x7c, 0x1
  movlw   0x08
  subwf   0x7c, 0x0
  btfsc   0x03, 0x0
	clrf    0x7c

  movlw   0x01
  movlb   0x00
  subwf   buf2size, 0x1
old_13f:
  movlb   0x0e
  bsf     0x19, 0x4	; PIE3.TXIE
  return
pin_init:
  movlb   0x00
  clrf    0x16 	; LATA
  clrf    0x17	; LATB
  movlw   0x41
  movwf   0x18	; LATC
  movlw   0xf0
  movwf   0x11	; TRISA
  movlw   0xff	;
  movwf   0x12	; trisb
  movlw   0xfe
  movwf   0x13	; trisc
  movlw   0xfd
  movlb   0x1e
  movwf   0x4e	; anselc
  movlw   0xff
  movwf   0x43	; anselb
  movlw   0xff
  movwf   0x38	; ansela
  movlw   0x08
  movwf   0x65	; wpue
  movlw   0xff
  movwf   0x44	; wpub
  movlw   0xff
  movwf   0x39	; wpua
  movlw   0xff
  movwf   0x4f	; wpuc
  clrf    0x3a	; odcona
  clrf    0x45	; odconb
  clrf    0x50	; odconc
  movlw   0xff
  movwf   0x3b	; slrcona
  movlw   0xff
  movwf   0x46	; slrconb
  movlw   0xff
  movwf   0x51	; slrconc
  movlw   0x10
  movwf   0x20	; rc0pps
  movlw   0x11
  movlb   0x1d	;
  movwf   0x4b	; RXPPS
  return
transmit_isr:
  movlw   0x08
  movlb   0x00
  subwf   buf2size, 0x0
  btfsc   0x03, 0x0
  goto    old_18b
  movf    0x3a, 0x0
  addlw   0x30
  movwf   0x06
  clrf    0x07
  movf    0x01, 0x0
  movlb   0x02
  movwf   0x1a
  movlw   0x01
  movwf   0x70
  movf    0x70, 0x0
  movlb   0x00
  addwf   0x3a, 0x1
  movlw   0x08
  subwf   0x3a, 0x0
  btfsc   0x03, 0x0
  clrf    0x3a
  movlw   0x01
  movwf   0x70
  movf    0x70, 0x0
  addwf   buf2size, 0x1
  return
old_18b:
  movlb   0x0e
  bcf     0x19, 0x4
  return
hw_receive:
  movlb   0x02
  movf    rxhead, 0x0 		; FSR2 = rxhead+0x28
  addlw   0x28
  movwf   0x06
  clrf    0x07
  movf    0x19, 0x0  ; RCREG to 0x70
  movwf   0x01			; RCREG to INDF1
  movlw   0x01
  movwf   0x70
  movf    0x70, 0x0
  addwf   rxhead, 0x1
  movlw   0x08
  subwf   rxhead, 0x0
  btfsc   0x03, 0x0
  clrf    rxhead
  movlw   0x01
  movwf   0x70
  movf    0x70, 0x0
  movlb   0x00
  addwf   rxcount, 0x1
  return
;;;; put string in 74/75 w/o newline
;;;; put string from fsr0
old_01ab:
  call    write_char_3
put_string_b
  moviw   0++
  btfss   0x03, 0x2
  goto    old_01ab
  return
receive_and_display:
  retlw   0x31
  retlw   0x65
  retlw   0x63
  retlw   0x65
  retlw   0x69
  retlw   0x76
  retlw   0x65
  retlw   0x20
  retlw   0x61
  retlw   0x6e
  retlw   0x64
  retlw   0x20
  retlw   0x44
  retlw   0x69
  retlw   0x73
  retlw   0x70
  retlw   0x6c
  retlw   0x61
  retlw   0x79
  retlw   0x00
system_init:
  call    clean_pmd
  call    pin_init
  call    osc_init
  call    eusart_init
  return
puts:
  call    put_string_b
  movlw   0x0a
  call    write_char_3
  return

osc_init:
  movlw   0x62
  movlb   0x11
  movwf   0x0d 	; osccon1
  clrf    0x0f	; osccon3
  clrf    0x11	; oscen
  movlw   0x02
  movwf   0x13	; oscfrq
  clrf    0x12	; osctune
  return
clean_pmd:
  movlb   0x0f
  clrf    0x16 	;pmd0 - pmd5
  clrf    0x17
  clrf    0x18
  clrf    0x19
  clrf    0x1a
  clrf    0x1b
  return
system_init_2
  clrwdt
frame_error_handle:
  clrf    0x00
  addfsr  4, .1
  decfsz  0x09, 0x1
  goto    frame_error_handle
  retlw   0x00
write_char_3
  movwf   0x73
  movf    0x73, 0x0
  call    write_char
  return

  movf    0x72, 0x0
  movlb   0x00
  movwf   0x44
  movf    0x71, 0x0
  movwf   0x43
  return

;;; Overrun error handler
overrun_handler:
  movlb   0x02
  bcf     0x1d, 0x4
  bsf     0x1d, 0x4
  return
;;; default error handler
err_handler:
  goto    hw_receive

  CONFIG RSTOSC=HFINT1, FEXTOSC=OFF, ZCD=ON, WDTE=OFF, LVP=OFF
  end
