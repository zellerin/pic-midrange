
%.h:
	sed -i '/extern /d' $@
	sed -n '/global/{s/global/extern/;/\*\*/!p}' $^ |tee -a $@

library/stack.h: library/stack/*.asm
library/print.h: library/print/*.asm
library/eeprom.h: library/eeprom-read.asm
library/18b20.h: library/18b20.asm library/print-temp.asm
