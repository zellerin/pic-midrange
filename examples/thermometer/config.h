;; -*- mode:pic-asm; coding: utf-8 -*-
	list p=12f675
	title "Pins and other settings."
	include "p12f675.inc"

THERMO_PIN equ 0
UART_PIN   equ 4

PORTA	equ GPIO	
TRISA	equ TRISIO

STACK_SIZE equ 0x10
