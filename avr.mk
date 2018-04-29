# Copyright 2017 jem@seethis.link
# Licensed under the MIT license (http://opensource.org/licenses/MIT)

# Based on the WinAVR Makefile Template written by Eric B. Weddington, Jörg
# Wunsch, et al which is released under the Public Domain.
#

ifndef AVR_MKFILE_DIR
  AVR_MKFILE_DIR = ./avr-makefile
endif

#######################################################################
#                          Compiler Options                           #
#######################################################################

#---------------- Compiler Options C ----------------
#  -g*:          generate debugging information
#  -O*:          optimization level
#  -f...:        tuning, see GCC manual and avr-libc documentation
#  -Wall...:     warning level
#  -Wa,...:      tell GCC to pass this to the assembler.
#    -adhlns...: create assembler listing
CFLAGS += -g$(DEBUG)
CFLAGS += $(CDEFS)
CFLAGS += -O$(OPT)
CFLAGS += -fno-strict-aliasing
CFLAGS += -Wstrict-prototypes
CFLAGS += -Wa,-adhlns=$(@:%.o=%.lst)
CFLAGS += $(patsubst %,-I%,$(EXTRAINCDIRS))
CFLAGS += $(CSTANDARD)
CFLAGS += $(CONFIG_FLAGS)
# Show all warnings. Treat warnings as errors
CFLAGS += -Wall -Werror

#---------------- Compiler Options C++ ----------------
#  -g*:          generate debugging information
#  -O*:          optimization level
#  -f...:        tuning, see GCC manual and avr-libc documentation
#  -Wall...:     warning level
#  -Wa,...:      tell GCC to pass this to the assembler.
#    -adhlns...: create assembler listing
CPPFLAGS += -g$(DEBUG)
CPPFLAGS += $(CPPDEFS)
CPPFLAGS += -O$(OPT)
CPPFLAGS += -fno-exceptions
CPPFLAGS += -Wall
CPPFLAGS += -Wundef
CPPFLAGS += -Wa,-adhlns=$(@:%.o=%.lst)
CPPFLAGS += $(patsubst %,-I%,$(EXTRAINCDIRS))

#---------------- Assembler Options ----------------
#  -Wa,...:   tell GCC to pass this to the assembler.
#  -adhlns:   create listing
#  -gstabs:   have the assembler create line number information; note that
#             for use in COFF files, additional information about filenames
#             and function names needs to be present in the assembler source
#             files -- see avr-libc docs [FIXME: not yet described there]
#  -listing-cont-lines: Sets the maximum number of continuation lines of hex
#       dump that will be displayed for a given single line of source input.
ASFLAGS = $(ADEFS) -Wa,-adhlns=$(@:%.o=%.lst),-gstabs,--listing-cont-lines=100


#---------------- Linker Options ----------------
#  -Wl,...:     tell GCC to pass this to linker.
#    -Map:      create map file
#    --cref:    add cross reference to  map file
LDFLAGS += -Wl,-Map=$(TARGET_MAP),--cref
# LDFLAGS += -Wl,--relax
LDFLAGS += -Wl,--gc-sections
LDFLAGS += -flto

#---------------- common defines ----------------
# Place -D or -U options here for C sources
CDEFS += -DF_CPU=$(F_CPU)UL
CDEFS += -DF_USB=$(F_USB)UL
CDEFS += -DBOARD=BOARD_$(BOARD)
CDEFS += -DARCH=ARCH_$(ARCH)
CDEFS += -D __$(DEVICE)__

# Place -D or -U options here for ASM sources
ADEFS  = -DF_CPU=$(F_CPU)
ADEFS += -DF_USB=$(F_USB)UL
ADEFS += -DBOARD=BOARD_$(BOARD)
ADEFS += -DARCH=ARCH_$(ARCH)
ADEFS += -D __$(DEVICE)__

#######################################################################
#                              obj files                              #
#######################################################################

#Create lists of object files need to build the program
C_OBJ_FILES = $(patsubst %.c, $(OBJ_DIR)/%.o, $(C_SRC))
C_LST_FILES = $(patsubst %.c, $(OBJ_DIR)/%.lst, $(C_SRC))
ASM_OBJ_FILES = $(patsubst %.S, $(OBJ_DIR)/%.o, $(ASM_SRC))
ASM_LST_FILES = $(patsubst %.S, $(OBJ_DIR)/%.lst, $(ASM_SRC))

OBJ = $(C_OBJ_FILES) $(ASM_OBJ_FILES)
LST = $(C_LST_FILES) $(ASM_LST_FILES)

#######################################################################
#                        programs and commands                        #
#######################################################################

# Define programs and commands.
CC = avr-gcc
OBJCOPY = avr-objcopy
OBJDUMP = avr-objdump
SIZE = avr-size
AR = avr-ar rcs
NM = avr-nm
REMOVE = rm -f
REMOVEDIR = rm -fr

# Define Messages
# English
MSG_ERRORS_NONE = Errors: none
MSG_COFF = Converting to AVR COFF:
MSG_EXTENDED_COFF = Converting to AVR Extended COFF:
MSG_FLASH = Creating load file for Flash:
MSG_EEPROM = Creating load file for EEPROM:
MSG_EXTENDED_LISTING = Creating Extended Listing:
MSG_SYMBOL_TABLE = Creating Symbol Table:
MSG_LINKING = Linking:
MSG_COMPILING = Compiling C:
MSG_COMPILING_CPP = Compiling C++:
MSG_ASSEMBLING = Assembling:
MSG_CLEANING = Cleaning project:
MSG_CREATING_LIBRARY = Creating library:

#######################################################################
#                             extra flags                             #
#######################################################################

# Compiler flags to generate dependency files.
GENDEPFLAGS = -MMD -MP -MF $(DEP_DIR)/$(@F).d

# Combine all necessary flags and optional flags.
# Add target processor to flags.
ALL_CFLAGS = -mmcu=$(MCU) -I. $(CFLAGS) $(GENDEPFLAGS)
ALL_CPPFLAGS = -mmcu=$(MCU) -I. -x c++ $(CPPFLAGS) $(GENDEPFLAGS)
ALL_ASFLAGS = -mmcu=$(MCU) -I. -x assembler-with-cpp $(ASFLAGS)

#######################################################################
#                              recepies                               #
#######################################################################

# Default target.
all: build

# Change the build target to build a HEX file or a library.
build: elf hex
#eep lss sym
#build: lib

$(BUILD_TARGET_DIR):
	mkdir -p $(BUILD_TARGET_DIR)

print_build_info:
	@echo "### Build settings ###"
	@echo -e "TARGET:\t$(TARGET)"
	@echo -e "BOARD:\t$(BOARD)"
	@echo -e "MCU:\t$(MCU)"
	@echo "compiler c flags:"
	@echo "$(ALL_CFLAGS)"
	@echo ""

elf: $(BUILD_TARGET_DIR) $(TARGET_ELF)
hex: $(BUILD_TARGET_DIR) $(TARGET_HEX)
fuse: $(BUILD_TARGET_DIR) $(TARGET_FUSE)
lock: $(BUILD_TARGET_DIR) $(TARGET_LOCK)
eep: $(BUILD_TARGET_DIR) $(TARGET_EEP)
lss: $(BUILD_TARGET_DIR) $(TARGET_LSS)
sym: $(BUILD_TARGET_DIR) $(TARGET_SYM)
LIBNAME=lib$(TARGET).a
lib: $(LIBNAME)


# Display size of file.
HEXSIZE = $(SIZE) --target=$(FORMAT) $(TARGET_HEX)
ELFSIZE = $(SIZE) $(MCU_FLAG) $(FORMAT_FLAG) $(TARGET_ELF)
MCU_FLAG = $(shell $(SIZE) --help | grep -- --mcu > /dev/null && echo --mcu=$(MCU) )
FORMAT_FLAG = $(shell $(SIZE) --help | grep -- --format=.*avr > /dev/null && echo --format=avr )

BUILD_IDENTIFIER = $(BUILD_DIR)_$(BOARD)_$(MCU)
OLD_FLASH_SIZE = $(BUILD_DIR)/.old_flash_size_$(BUILD_IDENTIFIER).o
OLD_RAM_SIZE = $(BUILD_DIR)/.old_ram_size_$(BUILD_IDENTIFIER).o

pretty_size: # would be nice to add get total ram size
	@if test -f $(TARGET_ELF); then \
        echo "=== ELF Size Information ($(TARGET)) ==="; \
	echo "$$($(SIZE) $(TARGET_ELF))";  \
        echo "=== Size Information ($(TARGET)) ==="; \
        oldFlashSize=$$(cat $(OLD_FLASH_SIZE) 2>/dev/null) ; \
        oldRamSize=$$(cat $(OLD_RAM_SIZE) 2>/dev/null) ; \
        if [[ $$oldFlashSize -eq "" ]]; then \
            oldFlashSize=0; \
        fi; \
        if [[ $$oldRamSize -eq "" ]]; then \
            oldRamSize=0; \
        fi; \
        sizeData=$$($(ELFSIZE)); \
        newFlashSize=$$( echo "$$sizeData" | grep Program | awk '{ printf $$2 }'); \
        newRamSize=$$( echo "$$sizeData" | grep Data | awk '{ printf $$2 }'); \
        echo flash size: $$newFlashSize ; \
        echo flash delta: $$(($$newFlashSize - $$oldFlashSize)) ; \
        echo ram size: $$newRamSize ;\
        echo ram delta: $$(($$newRamSize - $$oldRamSize)) ; \
        echo $$newFlashSize > $(OLD_FLASH_SIZE) ; \
        echo $$newRamSize > $(OLD_RAM_SIZE) ; \
        echo; \
    fi

# Create final output files (.hex, .eep) from ELF output file.
%.hex: %.elf
	@echo $(MSG_FLASH) $@
	@$(OBJCOPY) -O $(FORMAT) -R .eeprom -R .fuse -R .lock $< $@

%.fuse: %.elf
	@echo $(MSG_FLASH) $@
	@$(OBJCOPY) -O $(FORMAT) -j .fuse $< $@

# # extract the fuse section from the elf file
# $(TARGET).fuse: $(TARGET).elf
# 	avr-objcopy -O $(FORMAT) -j .fuse --change-section-lma .fuse=$(FUSE_SECTION_START) $< $@

%.lock: %.elf
	@echo $(MSG_FLASH) $@
	@$(OBJCOPY) -O $(FORMAT) -j .lock $< $@

%.eep: %.elf
	@echo $(MSG_EEPROM) $@
	-$(OBJCOPY) -j .eeprom --set-section-flags=.eeprom="alloc,load" \
	--change-section-lma .eeprom=0 --no-change-warnings -O $(FORMAT) $< $@ || exit 0

# Create extended listing file from ELF output file.
%.lss: %.elf
	@echo $(MSG_EXTENDED_LISTING) $@
	@$(OBJDUMP) -h -S -z $< > $@

# Create a symbol table from ELF output file.
%.sym: %.elf
	@echo $(MSG_SYMBOL_TABLE) $@
	@$(NM) -n $< > $@


# Treat the makefiles as dependencies to all object files so that the project
# will be rebuilt automatically
$(OBJ): $(MAKEFILE_INC)

# Link: create ELF output file from object files.
.SECONDARY : $(TARGET_ELF)
.PRECIOUS : $(OBJ)
%.elf: $(OBJ)
	@echo $(MSG_LINKING) $@
	@$(CC) $(ALL_CFLAGS) $^ --output $@ $(LDFLAGS)

# Compile: create object files from C source files.
$(OBJ_DIR)/%.o : %.c
	@echo $(MSG_COMPILING) $<
	@mkdir -p $(dir $@)
	@mkdir -p $(DEP_DIR)
	@$(CC) -c $(ALL_CFLAGS) $< -o $@
#   build the assembly file as well if requested
	@if [[ "$(GENERATE_ASM)" ]]; then \
		$(CC) -S $(ALL_CFLAGS) $< -o $@.asm -fverbose-asm; \
	fi

# Assemble: create object files from assembler source files.
$(OBJ_DIR)/%.o : %.S
	@echo $(MSG_ASSEMBLING) $<
	@mkdir -p $(dir $@)
	@$(CC) -c $(ALL_ASFLAGS) $< -o $@

# Compile: create assembler files from C source files.
%.s : %.c
	@$(CC) -S $(ALL_CFLAGS) $< -o $@

# Target: clean project.
clean:
	@echo
	@echo $(MSG_CLEANING)
	$(REMOVE) $(TARGET_HEX)
	$(REMOVE) $(TARGET_ELF)
	$(REMOVE) $(TARGET_FUSE)
	$(REMOVE) $(TARGET_EEP)
	$(REMOVE) $(TARGET_LSS)
	$(REMOVE) $(TARGET_SYM)
	$(REMOVE) $(TARGET_MAP)
	$(REMOVEDIR) $(OBJ_DIR)
	$(REMOVEDIR) $(DEP_DIR)

# Include the dependency files.
-include $(wildcard $(DEP_DIR)/*)

.PHONY : all begin finish end pretty_size gccversion \
build elf hex eep lss sym coff extcoff clean print_build_info
# vim:noet:
