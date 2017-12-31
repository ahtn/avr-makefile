# program a board using an external programmer
program: $(TARGET_HEX)
	$(AVRDUDE_CMD) -U flash:w:$<:i

erase:
	$(AVRDUDE_CMD) -e
