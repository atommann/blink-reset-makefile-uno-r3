CC=avr-gcc
CFLAGS=-Wall -Os -DF_CPU=$(F_CPU) -mmcu=$(MCU)
MCU=atmega328p
#MCU=atmega2560
F_CPU=16000000UL

OBJCOPY=avr-objcopy
BIN_FORMAT=ihex

# FreeBSD
#PORT=/dev/cuaU0
#PORT=/dev/ttyUSB0
PORT=/dev/ttyACM0
#BAUD=9600
#BAUD=19200
BAUD=115200 # Arduino Uno R3, mega 2560
#BAUD=57600 # Arduino duemilanove
PROTOCOL=stk500v1
#PROTOCOL=stk500v2 # MEGA 2560
PART=$(MCU)
#AVRDUDE=avrdude -F -V
AVRDUDE=avrdude -F -D

RM=rm -f

.PHONY: all
all: blink.hex

blink.hex: blink.elf

blink.elf: blink.s

blink.s: blink.c

.PHONY: clean
clean:
	$(RM) blink.elf blink.hex blink.s

.PHONY: upload
upload: blink.hex
	stty -F $(PORT) hupcl
	#python -c "import serial, time; s = serial.Serial('/dev/ttyACM0', 57600); s.setDTR(True); time.sleep(1); s.setDTR(False); s.close()"
	#perl -MDevice::SerialPort -e 'Device::SerialPort->new("/dev/ttyACM0")->pulse_dtr_on(1000)';
	$(AVRDUDE) -c $(PROTOCOL) -p $(PART) -P $(PORT) -b $(BAUD) -U flash:w:$<

%.elf: %.s ; $(CC) $(CFLAGS) -s -o $@ $<

%.s: %.c ; $(CC) $(CFLAGS) -S -o $@ $<

%.hex: %.elf ; $(OBJCOPY) -O $(BIN_FORMAT) -R .eeprom $< $@

