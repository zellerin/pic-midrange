;;;  -*- mode:pic-asm -*-
        include "config.h"
        title "lcd module test"
        radix DEC

	global mswait, short_wait

	udata_shr
duration:
        ;; used by short_wait as a parameter
        res .1

	code
mswait:
        ;; wait about W*(256*3+2+8) ops
	;; i.e. about W*778 µsec on 4Mhz
        clrf    duration
        call    short_wait_dur
        addlw   0xff
        btfsc   STATUS, Z
        return
        goto    mswait
short_wait:
	;; burn duration*3+2 ops
	;; on 4Mhz, op is 1 µsec
	;; so max is 770 µsec
	movwf duration
short_wait_dur:
        ;; burn duration*3+1 ops
	;; duration is 1 to 256
        decfsz  duration, f
        goto short_wait_dur
        return

	end
