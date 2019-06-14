# Makefile

SRC = $(wildcard *.cpp)
OBJ = $(wildcard *.o)

# Extract Vivado HLS include path
VHLS_PATH := $(dir $(shell which vivado_hls))..
VHLS_INC ?= ${VHLS_PATH}/include

# Specify compilation flags
CFLAGS = -std=c++11 -g -I${VHLS_INC}

# Compile & run implementation
os_pfb: $(SRC)
	g++ ${CFLAGS} $(SRC) -o $@.bin

run: os_pfb.bin
	./$<

clean:
	@echo "Clean up output files"
	rm -rf *.bin vivado_hls.log *~
