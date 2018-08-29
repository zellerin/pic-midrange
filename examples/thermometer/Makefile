PICLIBS=18b20.o wait.o eeprom.o put-reg.o 115k.o uart/put-fn.o
PICLIBS+=stack/init.o stack/push.o stack/pop.o error.o print-temp.o
include ../Makefile

MAYBE-CALIBRATE=osccal-live.o
PICNAME=PIC12F675

osccal-live.o: ../calibrate.asm
	gpasm -c $< -o $@ -D VALUE=0x12

calibrate.o: ../calibrate.asm
	gpasm -c $< -o $@ -D VALUE=0x80
