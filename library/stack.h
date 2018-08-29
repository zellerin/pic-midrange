;;;; -*- mode: pic-asm -*-

	variable HAD_PUSH
	variable HAD_ALLOC
	variable HAD_POP
	
PUSH	macro
	IF (HAD_PUSH == 0)
	extern stack_push
HAD_PUSH set 1
	ENDIF
	call stack_push
	endm

ALLOC	macro
	IF (HAD_ALLOC == 0)
	extern stack_alloc
HAD_ALLOC set 1
	ENDIF
	call stack_alloc
	endm

POP	macro
	IF (HAD_POP == 0)
	extern stack_pop
HAD_POP set 1
	ENDIF
	call stack_pop
	endm
