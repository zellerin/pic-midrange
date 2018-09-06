;;;; -*- mode: pic-asm -*-

PUSH	macro
	call stack_push
	endm

ALLOC	macro
	call stack_alloc
	endm

POP	macro
	call stack_pop
	endm

	;; Functions
	extern stack_push	; Put W to INDF and advance FSR.
	extern stack_alloc	; Advance FSR.
	extern stack_init 	; Initialize stack. Has to be called with STACK_SIZE set.
	extern stack_pop 	; Decrease FSR and put INDF to W.
