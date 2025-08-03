# Makefile for VeronesePresentation

CXX = g++
CXXFLAGS = -O2 -std=c++17

SRC_DIR = src
BIN_DIR = bin
TARGET = $(BIN_DIR)/full_pipeline

SRC_FILES = \
  full_pipeline.cpp \
  read_macaulay2.cpp \
  generate_input_file.cpp \
  parseHilbertBasis.cpp \
  write_macaulay2.cpp

SOURCES = $(addprefix $(SRC_DIR)/, $(SRC_FILES))

all: $(TARGET)

$(TARGET): $(SOURCES)
	mkdir -p $(BIN_DIR)
	$(CXX) $(CXXFLAGS) -o $@ $^

clean:
	rm -rf $(BIN_DIR)
