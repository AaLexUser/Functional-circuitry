.PHONY: all clean

PROJECT_DIR = $(shell pwd)
BUILD_DIR = $(PROJECT_DIR)/build
SRC_DIR = $(PROJECT_DIR)/src
TARGET = fifo
FLAGS = -Wall -I /Users/aleksejlapin/ITMO/DigitalCircutBook

gtkwave: $(BUILD_DIR)/$(TARGET).vcd
	gtkwave $<

all: $(BUILD_DIR)/$(TARGET)_tb.vvp $(BUILD_DIR)/$(TARGET).vcd

$(BUILD_DIR)/$(TARGET).vcd: $(BUILD_DIR)/$(TARGET)_tb.vvp
	vvp $<

$(BUILD_DIR)/$(TARGET)_tb.vvp: $(SRC_DIR)/$(TARGET).v $(SRC_DIR)/$(TARGET)_tb.v
	iverilog $(FLAGS) -o $@ $(SRC_DIR)/$(TARGET)_tb.v

clean:
	rm -f $(BUILD_DIR)/$(TARGET)_tb.vvp $(BUILD_DIR)/$(TARGET).vcd
