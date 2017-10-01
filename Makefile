all: utils.a

demo: demo/lcdn.hex

sim: demo
	gpsim demo/test.stc

%.hex: %.o utils.a
	gplink -o $@ -c $^

utils.a:  utils.a(lcd-init.o wait.o eeprom.o lcd.o)

utils.a(%.o): %.o
	if [[ -f utils.a ]]; then gplib -r utils.a $< ; else gplib -c utils.a $< ; fi

%.o: %.asm
	gpasm -c $<
