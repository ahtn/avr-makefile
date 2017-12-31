#######################################################################
#                        board config options                         #
#######################################################################

# Note: Specific board configs are stored in the `boards` directory.

ifndef BOARD_DIR
    BOARD_DIR = boards
endif

ifndef BOARD
    BOARD = default
endif

ifndef BUILD_DIR
    BUILD_DIR = build
endif

ifneq ("$(wildcard boards/$(BOARD)/config.mk)","")
    include $(BOARD_DIR)/$(BOARD)/config.mk
    TARGET = $(TARGET_BASE_NAME)-$(BOARD)-$(MCU)
else
    $(error "Unknown board $(BOARD)")
endif
