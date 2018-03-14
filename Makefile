all: utils.a
PICLIBS=lcd-init.o wait.o eeprom.o
PICLIBS+=lcd.o stack.o 18b20.o

demo: demo/lcdn.hex

sim: demo
	gpsim demo/test.stc

clean:
	rm -f *.o *.a demo/lcdn.hex

%.hex: %.o utils.a
	gplink -o $@ -c $^

utils.a: $(PICLIBS)
	gplib -c utils.a $^

%.o: %.asm
	gpasm -c $<

run:
	~/staging/pickit/pk2cmdv1.20LinuxMacSource/pk2cmd /PPIC16F630 /T /R

program:
	~/staging/pickit/pk2cmdv1.20LinuxMacSource/pk2cmd /PPIC16F630 /T /R /Fdemo/lcdn.hex /M
