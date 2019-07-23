             .org 0
0000:  3180  movlp   0x00
0001:  2829  goto    0x0029
           ;;; interrupt
             .org 4
0004:  147e  bsf     0x7e, 0x0
0005:  3180  movlp   0x00
0006:  1f0b  btfss   0x0b, 0x6	; INTCON.PEIE
0007:  2809  goto    0x0027
0008:  280a  nop
0009:  2827  nop
000a:  002e  movlb   0x0e
000b:  1e19  btfss   0x19, 0x4	; PIE3.TXIE
000c:  280e  goto    0x0017
000d:  280f  nop
000e:  2817  nop
000f:  1e0f  btfss   0x0f, 0x4	; PIR3.TXIF
0010:  2812  goto    0x0017
0011:  2813  nop
0012:  2817  nop
0013:  3181  movlp   0x01
0014:  216b  call    0x016b	; transmit ISR
0015:  3180  movlp   0x00
0016:  2827  goto    0x0027
0017:  1e99  btfss   0x19, 0x5	; PIE3.RCIE
0018:  281a  goto    0x0027
0019:  281b  nop
001a:  2827  nop
001b:  1e8f  btfss   0x0f, 0x5	; PIR3.RCIF
001c:  281e  goto    0x0027
001d:  281f  nop
001e:  2827  nop
001f:  3180  movlp   0x00
0020:  2079  call    isr_receive
0021:  3180  movlp   0x00
0022:  2827  nop
0023:  2827  nop
0024:  2827  nop
0025:  2827  nop
0026:  2827  nop
0027:  107e  bcf     0x7e, 0x0
0028:  0009  retfie
0029:  3180  nop
002a:  282b  nop
           ;;; init
002b:  01fa  clrf    0x7a
002c:  01fb  clrf    0x7b
002d:  01fc  clrf    0x7c
           ;;; FSR0 = 0x20
002e:  3020  movlw   0x20
002f:  0084  movwf   0x04
0030:  3000  movlw   0x00
0031:  0085  movwf   0x05

0032:  301b  movlw   0x1b
0033:  3182  movlp   0x02
           ;;; call system init
0034:  2201  call    0x0201
0035:  3180  movlp   0x00
0036:  107e  bcf     0x7e, 0x0
0037:  0020  movlb   0x00
0038:  3180  movlp   0x00
0039:  28e5  goto    main
           ;;; eusart-init
003a:  002e  movlb   0x0e
003b:  1299  bcf     0x19, 0x5	; pie3 - rcie
003c:  3079  movlw   0x79	;  EUSART_SetRxInterruptHandler(EUSART_Receive_ISR);
003d:  00f1  movwf   0x71
003e:  3000  movlw   0x00
003f:  00f2  movwf   0x72
0040:  3182  movlp   0x02
0041:  2213  call    0x0213
0042:  3180  movlp   0x00
0043:  002e  movlb   0x0e
0044:  1219  bcf     0x19, 0x4	; pie3 - 0719
0045:  306b  movlw   0x6b	; EUSART_SetTxInterruptHandler(EUSART_Transmit_ISR);
0046:  00f1  movwf   0x71
0047:  3001  movlw   0x01
0048:  00f2  movwf   0x72
0049:  3182  movlp   0x02
004a:  220d  call    0x020d
004b:  3180  movlp   0x00
           ;;; USART
004c:  3008  movlw   0x08
004d:  0022  movlb   0x02
004e:  009f  movwf   0x1f 	; baud1con
004f:  3090  movlw   0x90
0050:  009d  movwf   0x1d	; rcsta
0051:  3024  movlw   0x24
0052:  009e  movwf   0x1e	; txsta
0053:  3019  movlw   0x19
0054:  009b  movwf   0x1b	; spbrgl
0055:  019c  clrf    0x1c	; spbrgh
0056:  3033  movlw   0x33	; EUSART_SetFramingErrorHandler(EUSART_DefaultFramingErrorHandler);
0057:  00f1  movwf   0x71
0058:  3002  movlw   0x02
0059:  00f2  movwf   0x72
005a:  3182  movlp   0x02
005b:  221f  call    0x021f
005c:  3180  movlp   0x00
005d:  302b  movlw   0x2b 	; EUSART_SetOverrunErrorHandler(EUSART_DefaultOverrunErrorHandler);
005e:  00f1  movwf   0x71
005f:  3002  movlw   0x02
0060:  00f2  movwf   0x72
0061:  3182  movlp   0x02
0062:  2219  call    0x0219
0063:  3180  movlp   0x00
0064:  302f  movlw   0x2f	;   EUSART_SetErrorHandler(EUSART_DefaultErrorHandler);
0065:  00f1  movwf   0x71
0066:  3002  movlw   0x02
0067:  00f2  movwf   0x72
0068:  3182  movlp   0x02
0069:  2225  call    0x0225
006a:  3180  movlp   0x00
006b:  0020  movlb   0x00
006c:  01b8  clrf    0x38	; txhead
006d:  01fc  clrf    0x7c	; txtail
006e:  01ba  clrf    0x3a	; buffer size remaining
006f:  3008  movlw   0x08
0070:  00f3  movwf   0x73
0071:  0873  movf    0x73, 0x0
0072:  00c5  movwf   0x45
0073:  01fb  clrf    0x7b	; rxhead
0074:  01fa  clrf    0x7a	; rxtail
0075:  01b9  clrf    0x39	; rxcount
0076:  002e  movlb   0x0e
0077:  1699  bsf     0x19, 0x5	; PIE3.RCIE
0078:  0008  return
           isr_receive:
0079:  087b  movf    0x7b, 0x0
007a:  3e20  addlw   0x20
007b:  0086  movwf   0x06
007c:  0187  clrf    0x07  ; FSR1 = 0x2*0x7b
007d:  0181  clrf    0x01  ; INDF1
007e:  0022  movlb   0x02
007f:  1d1d  btfss   0x1d, 0x2 ; RCSTA.FERR
0080:  2882  goto    0x008f
0081:  2883  nop
0082:  288f  nop
0083:  087b  nop
0084:  3e20  nop
0085:  0086  nop
0086:  0187  nop
0087:  1481  bsf     0x01, 0x1 ; INDF1
0088:  0020  movlb   0x00      ; goto *0x3f
0089:  0840  movf    0x40, 0x0
008a:  008a  movwf   0x0a
008b:  083f  movf    0x3f, 0x0
008c:  000a  callw
008d:  3180  nop
008e:  288f  nop
008f:  0022  movlb   0x02
0090:  1c9d  btfss   0x1d, 0x1 ; RCSTA.OERR
0091:  2893  goto    0x00a0
0092:  2894  nop
0093:  28a0  nop
0094:  087b  nop
0095:  3e20  nop
0096:  0086  nop
0097:  0187  nop
0098:  1501  bsf     0x01, 0x2 ; indf
0099:  0020  movlb   0x00      ; goto *0x3d
009a:  083e  movf    0x3e, 0x0
009b:  008a  movwf   0x0a
009c:  083d  movf    0x3d, 0x0
009d:  000a  callw
009e:  3180  nop
009f:  28a0  nop
00a0:  087b  nop
00a1:  3e20  nop
00a2:  0086  nop
00a3:  0187  nop
00a4:  0801  movf    0x01, 0x0
00a5:  1903  btfsc   0x03, 0x2   ; zero?
00a6:  28a8  goto    0x00b0
00a7:  28a9  nop
00a8:  28b0  nop
00a9:  0020  movlb   0x00 ; goto *0x3b
00aa:  083c  movf    0x3c, 0x0
00ab:  008a  movwf   0x0a
00ac:  083b  movf    0x3b, 0x0
00ad:  000a  callw
00ae:  3180  nop
00af:  28b4  nop
00b0:  3181  movlp   0x01
00b1:  218f  call    0x018f
00b2:  3180  nop
00b3:  28b4  nop
00b4:  0008  return
           ;;; receive
00b5:  01f2  clrf    0x72
00b6:  28b8  goto    0x00b8
00b7:  28b8  goto    0x00b8
00b8:  0020  movlb   0x00
00b9:  0839  movf    0x39, 0x0
00ba:  1903  btfsc   0x03, 0x2
00bb:  28bd  goto    0x00bd
00bc:  28be  goto    0x00be
00bd:  28b8  goto    0x00b8
00be:  28bf  goto    0x00bf
00bf:  087a  movf    0x7a, 0x0
00c0:  3e20  addlw   0x20
00c1:  0086  movwf   0x06
00c2:  0187  clrf    0x07
00c3:  0801  movf    0x01, 0x0
00c4:  00f1  movwf   0x71
00c5:  0871  movf    0x71, 0x0
00c6:  00b8  movwf   0x38
00c7:  087a  movf    0x7a, 0x0
00c8:  3e28  addlw   0x28
00c9:  0086  movwf   0x06
00ca:  0187  clrf    0x07
00cb:  0801  movf    0x01, 0x0
00cc:  00f1  movwf   0x71
00cd:  0871  movf    0x71, 0x0
00ce:  00f2  movwf   0x72
00cf:  3001  movlw   0x01
00d0:  00f1  movwf   0x71
00d1:  0871  movf    0x71, 0x0
00d2:  07fa  addwf   0x7a, 0x1
00d3:  3008  movlw   0x08
00d4:  027a  subwf   0x7a, 0x0
00d5:  1c03  btfss   0x03, 0x0
00d6:  28d8  goto    0x00d8
00d7:  28d9  goto    0x00d9
00d8:  28db  goto    0x00db
00d9:  01fa  clrf    0x7a
00da:  28db  goto    0x00db
00db:  002e  movlb   0x0e
00dc:  1299  bcf     0x19, 0x5
00dd:  3001  movlw   0x01
00de:  0020  movlb   0x00
00df:  02b9  subwf   0x39, 0x1
00e0:  002e  movlb   0x0e
00e1:  1699  bsf     0x19, 0x5
00e2:  0872  movf    0x72, 0x0
00e3:  28e4  goto    0x00e4
00e4:  0008  return
           main:
00e5:  3181  movlp   0x01
00e6:  21d7  call    0x01d7 	; system init
00e7:  3180  movlp   0x00
00e8:  178b  bsf     0x0b, 0x7 	; intcon
00e9:  170b  bsf     0x0b, 0x6	; intcon
00ea:  30c3  movlw   0xc3	; puts argument start
00eb:  00f7  movwf   0x77
00ec:  3081  movlw   0x81
00ed:  00f8  movwf   0x78
00ee:  3181  movlp   0x01
00ef:  21e4  call    0x01e4	; puts
00f0:  3180  movlp   0x00
00f1:  28f2  goto    0x00f2
           main_loop
00f2:  3180  movlp   0x00
00f3:  20b5  call    0x00b5
00f4:  3180  movlp   0x00
00f5:  00f9  movwf   0x79
00f6:  0879  movf    0x79, 0x0
00f7:  0020  movlb   0x00
00f8:  00c6  movwf   0x46
00f9:  0846  movf    0x46, 0x0
00fa:  3181  movlp   0x01
00fb:  2114  call    write_char
00fc:  3180  movlp   0x00
00fd:  300a  movlw   0x0a
00fe:  3181  movlp   0x01
00ff:  2114  call    write_char
0100:  3180  movlp   0x00
0101:  304f  movlw   0x4f
0102:  3181  movlp   0x01
0103:  2114  call    write_char
0104:  3180  movlp   0x00
0105:  306b  movlw   0x6b
0106:  3181  movlp   0x01
0107:  2114  call    write_char
0108:  3180  movlp   0x00
0109:  303e  movlw   0x3e
010a:  3181  movlp   0x01
010b:  2114  call    write_char
010c:  3180  movlp   0x00
010d:  0020  movlb   0x00
010e:  0846  movf    0x46, 0x0
010f:  0096  movwf   0x16
0110:  28f2  goto    main_loop
0111:  28f2  goto    main_loop
0112:  3180  movlp   0x00
0113:  2829  goto    0x0029
           write_char:
0114:  00f2  movwf   0x72
0115:  2917  goto    0x0117
0116:  2917  goto    0x0117
0117:  0020  movlb   0x00
0118:  0845  movf    0x45, 0x0
0119:  1903  btfsc   0x03, 0x2	; while buffer remaining
011a:  291c  goto    0x011c
011b:  291d  goto    0x011d
011c:  2917  goto    0x0117
011d:  002e  movlb   0x0e
011e:  1a19  btfsc   0x19, 0x4	; PIE3.TXIE
011f:  2921  goto    0x0121
0120:  2922  goto    0x0122
0121:  2926  goto    0x0126
0122:  0872  movf    0x72, 0x0
0123:  0022  movlb   0x02
0124:  009a  movwf   0x1a
0125:  293f  goto    0x013f
0126:  1219  bcf     0x19, 0x4
0127:  0872  movf    0x72, 0x0
0128:  00f1  movwf   0x71
0129:  087c  movf    0x7c, 0x0
012a:  3e30  addlw   0x30
012b:  0086  movwf   0x06
012c:  0187  clrf    0x07
012d:  0871  movf    0x71, 0x0
012e:  0081  movwf   0x01
012f:  3001  movlw   0x01
0130:  00f1  movwf   0x71
0131:  0871  movf    0x71, 0x0
0132:  07fc  addwf   0x7c, 0x1
0133:  3008  movlw   0x08
0134:  027c  subwf   0x7c, 0x0
0135:  1c03  btfss   0x03, 0x0
0136:  2938  goto    0x0138
0137:  2939  goto    0x0139
0138:  293b  goto    0x013b
0139:  01fc  clrf    0x7c
013a:  293b  goto    0x013b
013b:  3001  movlw   0x01
013c:  0020  movlb   0x00
013d:  02c5  subwf   0x45, 0x1
013e:  293f  goto    0x013f
013f:  002e  movlb   0x0e
0140:  1619  bsf     0x19, 0x4	; PIE3.TXIE
0141:  0008  return
           ;;; init ports - pin_manager_initialize
0142:  0020  movlb   0x00
0143:  0196  clrf    0x16 	; LATA
0144:  0197  clrf    0x17	; LATB
0145:  3041  movlw   0x41
0146:  0098  movwf   0x18	; LATC
0147:  30f0  movlw   0xf0
0148:  0091  movwf   0x11	; TRISA
0149:  30ff  movlw   0xff	;
014a:  0092  movwf   0x12	; trisb
014b:  30fe  movlw   0xfe
014c:  0093  movwf   0x13	; trisc
014d:  30fd  movlw   0xfd
014e:  003e  movlb   0x1e
014f:  00ce  movwf   0x4e	; anselc
0150:  30ff  movlw   0xff
0151:  00c3  movwf   0x43	; anselb
0152:  30ff  movlw   0xff
0153:  00b8  movwf   0x38	; ansela
0154:  3008  movlw   0x08
0155:  00e5  movwf   0x65	; wpue
0156:  30ff  movlw   0xff
0157:  00c4  movwf   0x44	; wpub
0158:  30ff  movlw   0xff
0159:  00b9  movwf   0x39	; wpua
015a:  30ff  movlw   0xff
015b:  00cf  movwf   0x4f	; wpuc
015c:  01ba  clrf    0x3a	; odcona
015d:  01c5  clrf    0x45	; odconb
015e:  01d0  clrf    0x50	; odconc
015f:  30ff  movlw   0xff
0160:  00bb  movwf   0x3b	; slrcona
0161:  30ff  movlw   0xff
0162:  00c6  movwf   0x46	; slrconb
0163:  30ff  movlw   0xff
0164:  00d1  movwf   0x51	; slrconc
0165:  3010  movlw   0x10
0166:  00a0  movwf   0x20	; rc0pps
0167:  3011  movlw   0x11
0168:  003d  movlb   0x1d	;
0169:  00cb  movwf   0x4b	; RXPPS
016a:  0008  return
           ;;; Transmit ISR
016b:  3008  movlw   0x08
016c:  0020  movlb   0x00
016d:  0245  subwf   0x45, 0x0
016e:  1803  btfsc   0x03, 0x0
016f:  2971  goto    0x0171
0170:  2972  goto    0x0172
0171:  298b  goto    0x018b
0172:  083a  movf    0x3a, 0x0
0173:  3e30  addlw   0x30
0174:  0086  movwf   0x06
0175:  0187  clrf    0x07
0176:  0801  movf    0x01, 0x0
0177:  0022  movlb   0x02
0178:  009a  movwf   0x1a
0179:  3001  movlw   0x01
017a:  00f0  movwf   0x70
017b:  0870  movf    0x70, 0x0
017c:  0020  movlb   0x00
017d:  07ba  addwf   0x3a, 0x1
017e:  3008  movlw   0x08
017f:  023a  subwf   0x3a, 0x0
0180:  1c03  btfss   0x03, 0x0
0181:  2983  goto    0x0183
0182:  2984  goto    0x0184
0183:  2986  goto    0x0186
0184:  01ba  clrf    0x3a
0185:  2986  goto    0x0186
0186:  3001  movlw   0x01
0187:  00f0  movwf   0x70
0188:  0870  movf    0x70, 0x0
0189:  07c5  addwf   0x45, 0x1
018a:  298e  goto    0x018e
018b:  002e  movlb   0x0e
018c:  1219  bcf     0x19, 0x4
018d:  298e  goto    0x018e
018e:  0008  return
           hw_receive
018f:  0022  movlb   0x02
0190:  0819  movf    0x19, 0x0  ; RCREG
0191:  00f0  movwf   0x70
0192:  087b  movf    0x7b, 0x0
0193:  3e28  addlw   0x28
0194:  0086  movwf   0x06
0195:  0187  clrf    0x07
0196:  0870  movf    0x70, 0x0
0197:  0081  movwf   0x01
0198:  3001  movlw   0x01
0199:  00f0  movwf   0x70
019a:  0870  movf    0x70, 0x0
019b:  07fb  addwf   0x7b, 0x1
019c:  3008  movlw   0x08
019d:  027b  subwf   0x7b, 0x0
019e:  1c03  btfss   0x03, 0x0
019f:  29a1  goto    0x01a4
01a0:  29a2  nop
01a1:  29a4  nop
01a2:  01fb  clrf    0x7b
01a3:  29a4  nop
01a4:  3001  movlw   0x01
01a5:  00f0  movwf   0x70
01a6:  0870  movf    0x70, 0x0
01a7:  0020  movlb   0x00
01a8:  07b9  addwf   0x39, 0x1
01a9:  0008  return
           ;;;; put string in 74/75 w/o newline
01aa:  29b8  goto    0x01b8
           ;;;; put string from fsr0
01ab:  0874  movf    0x74, 0x0
01ac:  0084  movwf   0x04
01ad:  0875  movf    0x75, 0x0
01ae:  0085  movwf   0x05
01af:  0800  movf    0x00, 0x0
01b0:  3182  movlp   0x02
01b1:  2207  call    0x0207
01b2:  3181  movlp   0x01
01b3:  3001  movlw   0x01
01b4:  07f4  addwf   0x74, 0x1
01b5:  3000  movlw   0x00
01b6:  3df5  addwfc  0x75, 0x1
01b7:  29b8  goto    0x01b8
           ;;;; put string in 74/75 w/o newline
01b8:  0874  movf    0x74, 0x0
01b9:  0084  movwf   0x04 ; fsr0
01ba:  0875  movf    0x75, 0x0
01bb:  0085  movwf   0x05
01bc:  0012  moviw   0++
01bd:  1d03  btfss   0x03, 0x2
01be:  29c0  goto    0x01c0
01bf:  29c1  goto    0x01c1
01c0:  29ab  goto    0x01ab
01c1:  29c2  goto    0x01c2
01c2:  0008  return
           ;;; Receive & display
01c3:  3452  retlw   0x52
01c4:  3465  retlw   0x65
01c5:  3463  retlw   0x63
01c6:  3465  retlw   0x65
01c7:  3469  retlw   0x69
01c8:  3476  retlw   0x76
01c9:  3465  retlw   0x65
01ca:  3420  retlw   0x20
01cb:  3461  retlw   0x61
01cc:  346e  retlw   0x6e
01cd:  3464  retlw   0x64
01ce:  3420  retlw   0x20
01cf:  3444  retlw   0x44
01d0:  3469  retlw   0x69
01d1:  3473  retlw   0x73
01d2:  3470  retlw   0x70
01d3:  346c  retlw   0x6c
01d4:  3461  retlw   0x61
01d5:  3479  retlw   0x79
01d6:  3400  retlw   0x00
           ;;; system init
01d7:  3181  movlp   0x01
01d8:  21f9  call    0x01f9 	; clean pmd
01d9:  3181  movlp   0x01
01da:  3181  movlp   0x01
01db:  2142  call    0x0142	; pin mgr init
01dc:  3181  movlp   0x01
01dd:  3181  movlp   0x01
01de:  21f0  call    0x01f0	; oscillator-initialize
01df:  3181  movlp   0x01
01e0:  3180  movlp   0x00
01e1:  203a  call    0x003a	; eusart-initialize
01e2:  3181  movlp   0x01
01e3:  0008  return
           ;;; puts
01e4:  0878  movf    0x78, 0x0
01e5:  00f5  movwf   0x75
01e6:  0877  movf    0x77, 0x0
01e7:  00f4  movwf   0x74
01e8:  3181  movlp   0x01
01e9:  21aa  call    0x01aa
01ea:  3181  movlp   0x01
01eb:  300a  movlw   0x0a
01ec:  3182  movlp   0x02
01ed:  2207  call    0x0207
01ee:  3181  movlp   0x01
01ef:  0008  return
           ;;;  oscilator-init
01f0:  3062  movlw   0x62
01f1:  0031  movlb   0x11
01f2:  008d  movwf   0x0d 	; osccon1
01f3:  018f  clrf    0x0f	; osccon3
01f4:  0191  clrf    0x11	; oscen
01f5:  3002  movlw   0x02
01f6:  0093  movwf   0x13	; oscfrq
01f7:  0192  clrf    0x12	; osctune
01f8:  0008  return
           ;;; clear pmd
01f9:  002f  movlb   0x0f
01fa:  0196  clrf    0x16 	;pmd0 - pmd5
01fb:  0197  clrf    0x17
01fc:  0198  clrf    0x18
01fd:  0199  clrf    0x19
01fe:  019a  clrf    0x1a
01ff:  019b  clrf    0x1b
0200:  0008  return
           ;;; system initialize?
0201:  0064  clrwdt
           ;;; framing error handler
0202:  0180  clrf    0x00
0203:  3101  addfsr  4, .1
0204:  0b89  decfsz  0x09, 0x1
0205:  2a02  goto    0x0202
0206:  3400  retlw   0x00
0207:  00f3  movwf   0x73
0208:  0873  movf    0x73, 0x0
0209:  3181  movlp   0x01
020a:  2114  call    write_char
020b:  3182  movlp   0x02
020c:  0008  return

020d:  0872  movf    0x72, 0x0
020e:  0020  movlb   0x00
020f:  00c4  movwf   0x44
0210:  0871  movf    0x71, 0x0
0211:  00c3  movwf   0x43
0212:  0008  return

0213:  0872  movf    0x72, 0x0
0214:  0020  movlb   0x00
0215:  00c2  movwf   0x42
0216:  0871  movf    0x71, 0x0
0217:  00c1  movwf   0x41
0218:  0008  return
0219:  0872  movf    0x72, 0x0
021a:  0020  movlb   0x00
021b:  00be  movwf   0x3e
021c:  0871  movf    0x71, 0x0
021d:  00bd  movwf   0x3d
021e:  0008  return
021f:  0872  movf    0x72, 0x0
0220:  0020  movlb   0x00
0221:  00c0  movwf   0x40
0222:  0871  movf    0x71, 0x0
0223:  00bf  movwf   0x3f
0224:  0008  return
0225:  0872  movf    0x72, 0x0
0226:  0020  movlb   0x00
0227:  00bc  movwf   0x3c
0228:  0871  movf    0x71, 0x0
0229:  00bb  movwf   0x3b
022a:  0008  return
           ;;; Overrun error handler
022b:  0022  movlb   0x02
022c:  121d  bcf     0x1d, 0x4
022d:  161d  bsf     0x1d, 0x4
022e:  0008  return
           ;;; default error handler
022f:  3181  movlp   0x01
0230:  218f  call    0x018f
0231:  3182  movlp   0x02
0232:  0008  return
0233:  0008  return
             .org 0x8000
8007:  3fec  dw      0x3fec
8008:  3bff  dw      0x3bff
8009:  3f9f  dw      0x3f9f
800a:  1fff  dw      0x1fff
800b:  3fff  dw      0x3fff
