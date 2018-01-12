# program a board using an external programmer
programmer: $(TARGET_HEX)
	$(AVRDUDE_CMD) -U flash:w:$<:i

programmer-erase:
	$(AVRDUDE_CMD) -e

# readback flash and eeprom
.PHONY:
readback:
	$(AVRDUDE_CMD) \
        -U flash:r:readback-flash.hex:i \
        -U eeprom:r:readback-eeprom.hex:i

.PHONY:
program-fuses:
	$(AVRDUDE_CMD) $(AVRDUDE_DEVICE_FUSE)

.PHONY:
program-lock:
	$(AVRDUDE_CMD) $(AVRDUDE_DEVICE_LOCK)
