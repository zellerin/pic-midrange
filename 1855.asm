  org 0
  movlp   0x00
  goto    init
;;; interrupt
  org 4
  bsf     0x7e, 0x0
  movlp   0x00
  btfss   0x0b, 0x6	; INTCON.PEIE
  goto    int_end
  movlb   0x0e
  btfss   0x19, 0x4	; PIE3.TXIE
  goto    int_rc
  btfss   0x0f, 0x4	; PIR3.TXIF
  goto    int_rc
  movlp   0x01
  call    0x016b	; transmit ISR
  movlp   0x00
  goto    int_end
int_rc:
  btfss   0x19, 0x5	; PIE3.RCIE
  goto    int_end
  btfss   0x0f, 0x5	; PIR3.RCIF
  goto    int_end
  movlp   0x00
  call    isr_receive
  movlp   0x00
int_end
  bcf     0x7e, 0x0
  retfie

  org 0x2b
init:
  clrf    0x7a
  clrf    0x7b
  clrf    0x7c
;;; FSR0 = 0x20
  movlw   0x20
  movwf   0x04
  movlw   0x00
  movwf   0x05

  movlw   0x1b
  movlp   0x02
;;; call system init
  call    0x0201
  movlp   0x00
  bcf     0x7e, 0x0
  movlb   0x00
  movlp   0x00
  goto    main
;;; eusart-init
  movlb   0x0e
  bcf     0x19, 0x5	; pie3 - rcie
  movlw   0x79	;  EUSART_SetRxInterruptHandler(EUSART_Receive_ISR);
  movwf   0x71
  movlw   0x00
  movwf   0x72
  movlp   0x02
  call    0x0213
  movlp   0x00
  movlb   0x0e
  bcf     0x19, 0x4	; pie3 - 0719
  movlw   0x6b	; EUSART_SetTxInterruptHandler(EUSART_Transmit_ISR);
  movwf   0x71
  movlw   0x01
  movwf   0x72
  movlp   0x02
  call    0x020d
  movlp   0x00
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
  movlw   0x33	; EUSART_SetFramingErrorHandler(EUSART_DefaultFramingErrorHandler);
  movwf   0x71
  movlw   0x02
  movwf   0x72
  movlp   0x02
  call    0x021f
  movlp   0x00
  movlw   0x2b 	; EUSART_SetOverrunErrorHandler(EUSART_DefaultOverrunErrorHandler);
  movwf   0x71
  movlw   0x02
  movwf   0x72
  movlp   0x02
  call    0x0219
  movlp   0x00
  movlw   0x2f	;   EUSART_SetErrorHandler(EUSART_DefaultErrorHandler);
  movwf   0x71
  movlw   0x02
  movwf   0x72
  movlp   0x02
  call    0x0225
  movlp   0x00
  movlb   0x00
  clrf    0x38	; txhead
  clrf    0x7c	; txtail
  clrf    0x3a	; buffer size remaining
  movlw   0x08
  movwf   0x73
  movf    0x73, 0x0
  movwf   0x45
  clrf    0x7b	; rxhead
  clrf    0x7a	; rxtail
  clrf    0x39	; rxcount
  movlb   0x0e
  bsf     0x19, 0x5	; PIE3.RCIE
  return
isr_receive:
  movf    0x7b, 0x0
  addlw   0x20
  movwf   0x06
  clrf    0x07  ; FSR1 = 0x2*0x7b
  clrf    0x01  ; INDF1
  movlb   0x02
  btfss   0x1d, 0x2 ; RCSTA.FERR
  goto    0x008f
  nop
  nop
  nop
  nop
  nop
  nop
  bsf     0x01, 0x1 ; INDF1
  movlb   0x00      ; goto *0x3f
  movf    0x40, 0x0
  movwf   0x0a
  movf    0x3f, 0x0
  callw
  nop
  nop
  movlb   0x02
  btfss   0x1d, 0x1 ; RCSTA.OERR
  goto    0x00a0
  nop
  nop
  nop
  nop
  nop
  nop
  bsf     0x01, 0x2 ; indf
  movlb   0x00      ; goto *0x3d
  movf    0x3e, 0x0
  movwf   0x0a
  movf    0x3d, 0x0
  callw
  nop
  nop
  nop
  nop
  nop
  nop
  movf    0x01, 0x0
  btfsc   0x03, 0x2   ; zero?
  goto    0x00b0
  nop
  nop
  movlb   0x00 ; goto *0x3b
  movf    0x3c, 0x0
  movwf   0x0a
  movf    0x3b, 0x0
  callw
  nop
  nop
  movlp   0x01
  call    0x018f
  nop
  nop
  return
;;; receive
  clrf    0x72
  goto    0x00b8
  goto    0x00b8
  movlb   0x00
  movf    0x39, 0x0
  btfsc   0x03, 0x2
  goto    0x00bd
  goto    0x00be
  goto    0x00b8
  goto    0x00bf
  movf    0x7a, 0x0
  addlw   0x20
  movwf   0x06
  clrf    0x07
  movf    0x01, 0x0
  movwf   0x71
  movf    0x71, 0x0
  movwf   0x38
  movf    0x7a, 0x0
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
  addwf   0x7a, 0x1
  movlw   0x08
  subwf   0x7a, 0x0
  btfss   0x03, 0x0
  goto    0x00d8
  goto    0x00d9
  goto    0x00db
  clrf    0x7a
  goto    0x00db
  movlb   0x0e
  bcf     0x19, 0x5
  movlw   0x01
  movlb   0x00
  subwf   0x39, 0x1
  movlb   0x0e
  bsf     0x19, 0x5
  movf    0x72, 0x0
  goto    0x00e4
  return
main:
  movlp   0x01
  call    0x01d7 	; system init
  movlp   0x00
  bsf     0x0b, 0x7 	; intcon
  bsf     0x0b, 0x6	; intcon
  movlw   0xc3	; puts argument start
  movwf   0x74
  movlw   0x81
  movwf   0x75
  movlp   0x01
  call    puts	; puts(0x81c3)
  movlp   0x00
  goto    0x00f2
main_loop
  movlp   0x00
  call    0x00b5
  movlp   0x00
  movwf   0x79
  movf    0x79, 0x0
  movlb   0x00
  movwf   0x46
  movf    0x46, 0x0
  movlp   0x01
  call    write_char
  movlw   0x0d
  call    write_char
  movlw   0x0a
  call    write_char
  movlp   0x00
  movlw   0x4f
  movlp   0x01
  call    write_char
  movlp   0x00
  movlw   0x6b
  movlp   0x01
  call    write_char
  movlp   0x00
  movlw   0x3e
  movlp   0x01
  call    write_char
  movlp   0x00
  movlb   0x00
  movf    0x46, 0x0
  movwf   0x16
  goto    main_loop
  goto    main_loop
  movlp   0x00
  goto    init
write_char:
  movwf   0x72
  goto    0x0117
  goto    0x0117
  movlb   0x00
  movf    0x45, 0x0
  btfsc   0x03, 0x2	; while buffer remaining
  goto    0x011c
  goto    0x011d
  goto    0x0117
  movlb   0x0e
  btfsc   0x19, 0x4	; PIE3.TXIE
  goto    0x0121
  goto    0x0122
  goto    0x0126
  movf    0x72, 0x0
  movlb   0x02
  movwf   0x1a
  goto    0x013f
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
  btfss   0x03, 0x0
  goto    0x0138
  goto    0x0139
  goto    0x013b
  clrf    0x7c
  goto    0x013b
  movlw   0x01
  movlb   0x00
  subwf   0x45, 0x1
  goto    0x013f
  movlb   0x0e
  bsf     0x19, 0x4	; PIE3.TXIE
  return
;;; init ports - pin_manager_initialize
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
;;; Transmit ISR
  movlw   0x08
  movlb   0x00
  subwf   0x45, 0x0
  btfsc   0x03, 0x0
  goto    0x0171
  goto    0x0172
  goto    0x018b
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
  btfss   0x03, 0x0
  goto    0x0183
  goto    0x0184
  goto    0x0186
  clrf    0x3a
  goto    0x0186
  movlw   0x01
  movwf   0x70
  movf    0x70, 0x0
  addwf   0x45, 0x1
  goto    0x018e
  movlb   0x0e
  bcf     0x19, 0x4
  goto    0x018e
  return
hw_receive:
  movlb   0x02
  movf    0x19, 0x0  ; RCREG
  movwf   0x70
  movf    0x7b, 0x0
  addlw   0x28
  movwf   0x06
  clrf    0x07
  movf    0x70, 0x0
  movwf   0x01
  movlw   0x01
  movwf   0x70
  movf    0x70, 0x0
  addwf   0x7b, 0x1
  movlw   0x08
  subwf   0x7b, 0x0
  btfss   0x03, 0x0
  goto    0x01a4
  nop
  nop
  clrf    0x7b
  nop
  movlw   0x01
  movwf   0x70
  movf    0x70, 0x0
  movlb   0x00
  addwf   0x39, 0x1
  return
;;;; put string in 74/75 w/o newline
  goto    0x01b8
;;;; put string from fsr0
  movf    0x74, 0x0
  movwf   0x04
  movf    0x75, 0x0
  movwf   0x05
  movf    0x00, 0x0
  movlp   0x02
  call    0x0207
  movlp   0x01
  movlw   0x01
  addwf   0x74, 0x1
  movlw   0x00
  addwfc  0x75, 0x1
  goto    0x01b8
;;;; put string in 74/75 w/o newline
  movf    0x74, 0x0
  movwf   0x04 ; fsr0
  movf    0x75, 0x0
  movwf   0x05
  moviw   0++
  btfss   0x03, 0x2
  goto    0x01c0
  goto    0x01c1
  goto    0x01ab
  goto    0x01c2
  return
;;; Receive & display
  retlw   0x52
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
;;; system init
  movlp   0x01
  call    0x01f9 	; clean pmd
  movlp   0x01
  movlp   0x01
  call    0x0142	; pin mgr init
  movlp   0x01
  movlp   0x01
  call    0x01f0	; oscillator-initialize
  movlp   0x01
  movlp   0x00
  call    0x003a	; eusart-initialize
  movlp   0x01
  return
puts:
  nop
  nop
  nop
  nop
  movlp   0x01
  call    0x01aa
  movlp   0x01
  movlw   0x0a
  movlp   0x02
  call    0x0207
  movlp   0x01
  return
;;;  oscilator-init
  movlw   0x62
  movlb   0x11
  movwf   0x0d 	; osccon1
  clrf    0x0f	; osccon3
  clrf    0x11	; oscen
  movlw   0x02
  movwf   0x13	; oscfrq
  clrf    0x12	; osctune
  return
;;; clear pmd
  movlb   0x0f
  clrf    0x16 	;pmd0 - pmd5
  clrf    0x17
  clrf    0x18
  clrf    0x19
  clrf    0x1a
  clrf    0x1b
  return
;;; system initialize?
  clrwdt
;;; framing error handler
feh:
  clrf    0x00
  addfsr  4, .1
  decfsz  0x09, 0x1
  goto    feh
  retlw   0x00
  movwf   0x73
  movf    0x73, 0x0
  movlp   0x01
  call    write_char
  movlp   0x02
  return

  movf    0x72, 0x0
  movlb   0x00
  movwf   0x44
  movf    0x71, 0x0
  movwf   0x43
  return

  movf    0x72, 0x0
  movlb   0x00
  movwf   0x42
  movf    0x71, 0x0
  movwf   0x41
  return
  movf    0x72, 0x0
  movlb   0x00
  movwf   0x3e
  movf    0x71, 0x0
  movwf   0x3d
  return
  movf    0x72, 0x0
  movlb   0x00
  movwf   0x40
  movf    0x71, 0x0
  movwf   0x3f
  return
  movf    0x72, 0x0
  movlb   0x00
  movwf   0x3c
  movf    0x71, 0x0
  movwf   0x3b
  return
;;; Overrun error handler
  movlb   0x02
  bcf     0x1d, 0x4
  bsf     0x1d, 0x4
  return
;;; default error handler
  movlp   0x01
  call    0x018f
  movlp   0x02
  return
  return

  CONFIG RSTOSC=HFINT1, FEXTOSC=OFF, ZCD=ON, WDTE=OFF, LVP=OFF
  end
