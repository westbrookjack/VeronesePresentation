CXX = g++
CXXFLAGS = -std=c++17
SOURCES = full_pipeline.cpp read_macaulay2.cpp generate_input_file.cpp parseHilbertBasis.cpp write_macaulay2.cpp
TARGET = bin/full_pipeline

all: $(TARGET)

$(TARGET): $(SOURCES)
	$(CXX) $(CXXFLAGS) -o $(TARGET) $(SOURCES)

clean:
	rm -f $(TARGET)
