all: utils.a

demo: demo/lcdn.hex

sim: demo
	gpsim demo/test.stc

%.hex: %.o utils.a
	gplink -o $@ -c $^

utils.a:  utils.a(lcd-init.o wait.o eeprom.o lcd.o stack.o 18b20.o)

utils.a(%.o): %.o
	if [[ -f utils.a ]]; then gplib -r utils.a $< ; else gplib -c utils.a $< ; fi

%.o: %.asm
	gpasm -c $<

run:
	~/staging/pickit/pk2cmdv1.20LinuxMacSource/pk2cmd /PPIC16F630 /T /R /Fdemo/lcdn.hex

program:
	~/staging/pickit/pk2cmdv1.20LinuxMacSource/pk2cmd /PPIC16F630 /T /R /Fdemo/lcdn.hex /M
