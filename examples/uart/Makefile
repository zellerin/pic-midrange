PICLIBS=115k.o eeprom.o	stack/init.o stack/push.o uart/put-fn.o error.o put-reg.o stack/pop.o

PICNAME=PIC12F675

include ../Makefile

calibrate:
	~/staging/pickit/pk2cmdv1.20LinuxMacSource/pk2cmd /PPIC12F629 /M /Fcalibrate.hex
