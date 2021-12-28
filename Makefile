# Makefile to automate the compiling process and free myself from memorizing commands
# Very alike the first part

C = gcc
CPP = g++
CFLAGS := -Wall -std=c11 -O2
CPPFLAGS := -Wall -Wno-register -std=c++17 -O2

# Scanner and Parser
LEX = flex
YACC = bison

# Directories
NOW_DIR = .
BUILD_DIR ?= $(NOW_DIR)/build
SOURCE_DIR = $(NOW_DIR)/source
TARGET_EXEC = compiler
TARGET_DIR = $(BUILD_DIR)/$(TARGET_EXEC)

# YACC OUTPUT
YACC_OUT = $(BUILD_DIR)/parser_e.tab.h $(BUILD_DIR)/parser_e.tab.c

# Necessary classes
CLASS_SOURCE = $(SOURCE_DIR)/tiggerclass.cpp $(SOURCE_DIR)/tiggerclass.h
CLASS_OUTPUT = $(BUILD_DIR)/tiggerclass.o

$(TARGET_DIR): $(BUILD_DIR)/scanner_e.cpp $(BUILD_DIR)/parser_e.tab.c $(CLASS_OUTPUT)
	$(CPP) $(CPPFLAGS) -o $@ -I $(SOURCE_DIR) $^

$(CLASS_OUTPUT): $(CLASS_SOURCE)
	$(CPP) $(CPPFLAGS) -c -o $@ -I $(SOURCE_DIR) $<

$(BUILD_DIR)/scanner_e.cpp: $(SOURCE_DIR)/scanner_e.l $(YACC_OUT)
	mkdir -p $(dir $@)
	$(LEX) -o $@ $<

$(YACC_OUT): $(SOURCE_DIR)/parser_e.y
	$(YACC) -v --defines=$(BUILD_DIR)/parser_e.tab.h --output=$(BUILD_DIR)/parser_e.tab.c $<

# Phony file for cleaning
.PHONY: clean
clean:
	rm -f $(BUILD_DIR)/*

.PHONY: test
test: $(TARGET_DIR)
	$(TARGET_DIR) -S -t test/test.in -o test/test.out