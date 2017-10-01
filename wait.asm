        list p=16F630,t=ON,c=132,n=80
        title "lcd module test"
        radix DEC
        include "p16f630.inc"

	global wait_1, short_wait

	udata_shr
duration:
        ;; used by short_wait as a parameter
        res .1

	code
wait_1:
        ;; wait about W*(256*3+2+8) ops
	;; i.e. about W*778 µsec on 4Mhz
        clrf    duration
        call    short_wait_dur
        addlw   0xff
        btfsc   STATUS, Z
        return
        goto    wait_1
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
