
# ifndef AVRDUDE_DEVICE_FUSES
AVRDUDE_DEVICE_FUSES=\
    -U lfuse:w:"0x$(LFUSE)":m \
    -U hfuse:w:"0x$(HFUSE)":m \
    -U efuse:w:"0x$(EFUSE)":m \
# endif
