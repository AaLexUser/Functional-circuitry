.PHONY: all clean

PROJECT_DIR = $(shell pwd)
BUILD_DIR = $(PROJECT_DIR)/build
SRC_DIR = $(PROJECT_DIR)/src
TEST_DIR = $(PROJECT_DIR)/testbench
TARGET = fifo
FLAGS = -Wall -I /Users/aleksejlapin/ITMO/Lab4

gtkwave: $(BUILD_DIR)/$(TARGET).vcd
	gtkwave $<

all: $(BUILD_DIR)/$(TARGET)_tb.vvp $(BUILD_DIR)/$(TARGET).vcd

$(BUILD_DIR)/$(TARGET).vcd: $(BUILD_DIR)/$(TARGET)_tb.vvp
	vvp $<

$(BUILD_DIR)/$(TARGET)_tb.vvp: $(SRC_DIR)/$(TARGET).v $(TEST_DIR)/$(TARGET)_tb.v
	iverilog $(FLAGS) -o $@ $(TEST_DIR)/$(TARGET)_tb.v

clean:
	rm -f $(BUILD_DIR)/$(TARGET)_tb.vvp $(BUILD_DIR)/$(TARGET).vcd