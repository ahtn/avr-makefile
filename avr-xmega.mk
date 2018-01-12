#######################################################################
#                 settings for different xmega chips                  #
#######################################################################

FUSE_SECTION_START=0x08F0020

# see avr-gcc for information on avrxmega2, avrxmega4, etc
# NOTE: haven't tested on all these chips
ifeq ($(MCU), atxmega16a4u)
  BOOT_SECTION_START = 0x004000
  BOOTLOADER_SIZE = 0x1000
  AVRDUDE_PART = x16a4
  LD_SCRIPT = avrxmega2.xn
  MCU_STRING = "ATxmega16a4u"
  MCU_FLASH_SIZE = 16
else ifeq ($(MCU), atxmega32a4u)
  BOOT_SECTION_START = 0x008000
  BOOTLOADER_SIZE = 0x1000
  AVRDUDE_PART = x32a4
  LD_SCRIPT = avrxmega2.xn
  MCU_STRING = "ATxmega32a4u"
  MCU_FLASH_SIZE = 32
else ifeq ($(MCU), atxmega64a4u)
  BOOT_SECTION_START = 0x010000
  BOOTLOADER_SIZE = 0x1000
  AVRDUDE_PART = x64a4
  LD_SCRIPT = avrxmega4.xn
  MCU_STRING = "ATxmega64a4u"
  MCU_FLASH_SIZE = 64
else ifeq ($(MCU), atxmega128a4u)
  BOOT_SECTION_START = 0x020000
  BOOTLOADER_SIZE = 0x2000
  AVRDUDE_PART = x128a4
  MCU_STRING = "ATxmega128a4u"
  MCU_FLASH_SIZE = 128
  # NOTE: avr-gcc says atxmega128a4u -> avrxmega7, but it also says avrxmega7
  # is for devices with more than 128KiB program memory and more than 64KiB
  # of RAM. So avrxmega7 is probably used with external RAM
  # LD_SCRIPT = avrxmega7.xn
  LD_SCRIPT = avrxmega6.xn
else
  $(error No part matches MCU='$(MCU)')
endif

CDEFS += -DMCU_STRING=\"$(MCU_STRING)\"

ifndef AVRDUDE_DEVICE_FUSES
AVRDUDE_DEVICE_FUSES=\
        -U fuse0:w:"0x$(FUSE0)":m \
        -U fuse1:w:"0x$(FUSE1)":m \
        -U fuse2:w:"0x$(FUSE2)":m \
        -U fuse4:w:"0x$(FUSE4)":m \
        -U fuse5:w:"0x$(FUSE5)":m
endif

ifndef AVRDUDE_DEVICE_LOCK
AVRDUDE_DEVICE_LOCK=\
        -U lock:w:"0x$(LOCKBITS)":m
endif
