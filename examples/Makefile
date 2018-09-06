LIBDIR=../../library
SBCL=sbcl
PK2CMD=~/staging/pickit/pk2cmdv1.20LinuxMacSource/pk2cmd
.PRECIOUS: %.o obj/%.o

all: main.hex

sim: sim.cod mem.hex
	gpsim simulate.stc

clean:
	rm -rf *.o *.lst *.co[df] *.map main.hex

sim.hex sim.cod: main.o lib.a  $(addprefix obj/, $(OBJS)) ../calibrate.o
	gplink -o $@ $^ -c -m

%.hex: %.o lib.a $(addprefix obj/, $(OBJS))
	gplink -o $(GPCFLAGS) $@ $^ -c -m

mem.hex: sim.hex
	$(SBCL) --script ../eeprom.lisp

obj/%.o: $(LIBDIR)/%.asm config.h
	install -d obj/stack obj/uart obj/print
	gpasm -c $< -o $@  -I $(LIBDIR)

lib.a:  $(addprefix obj/, $(PICLIBS))
	gplib -c $@ $^

%.o: %.asm config.h
	gpasm -c $< -I $(LIBDIR)

run:
	$(PK2CMD) /P$(PICNAME) /T /R

program-run:
	$(PK2CMD) /P$(PICNAME) /T /R /Fmain.hex

program:
	$(PK2CMD) /P$(PICNAME) /M /Fmain.hex

read:
	$(PK2CMD) /P$(PICNAME) /GF read-back.hex

%.a:
	gplib -c $@ $^

obj/stack.a: obj/stack/init.o obj/stack/push.o obj/stack/pop.o
obj/18b20.a: obj/18b20.o obj/print-temp.o
obj/print.a: obj/print/eeprom.o obj/print/put-reg.o
