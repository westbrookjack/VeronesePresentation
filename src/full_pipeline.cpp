#include <cstdio>
#include <vector>
#include <string>
#include <iostream>

// Step 1: Clean up all intermediate Normaliz files
void cleanupTempFiles(const std::string& inputPrefix) {
    std::vector<std::string> extensions = {
        ".in", ".out", ".gen", ".hil", ".err", ".det", ".syz"
    };

    for (const std::string& ext : extensions) {
        std::string filename = inputPrefix + ext;
        std::remove(filename.c_str());  // silently ignore if missing
    }
}

// Optional: if you want to reuse later
std::string getInputBaseName(const std::string& filename) {
    size_t lastSlash = filename.find_last_of("/\\");
    std::string name = (lastSlash == std::string::npos) ? filename : filename.substr(lastSlash + 1);
    size_t dot = name.find_last_of('.');
    return (dot == std::string::npos) ? name : name.substr(0, dot);
}

#include "read_macaulay2.h"
#include "generate_input_file.h"
#include "parseHilbertBasis.h"
#include "write_macaulay2.h"

int main() {
    std::string inputFile = "input.txt";
    std::string inputPrefix = getInputBaseName(inputFile);  // usually "input"
    std::string finalM2 = "output.m2";  // always write here

    // Step 1: Read {list, n} from input.txt
    std::vector<int> myList;
    int n;
    readMacaulay2Input(inputFile, myList, n);

    // Step 2: Write Normaliz .in file
    generateInputFile(myList, n, inputPrefix + ".in");

    // Step 3: Call Normaliz
    std::string command = "normaliz " + inputPrefix + ".in";
    int result = std::system(command.c_str());
    if (result != 0) {
        std::cerr << "Normaliz failed.\n";
        return 1;
    }

    // Step 4: Parse Hilbert basis from .out
    std::vector<std::vector<int>> hilbertBasis = extractHilbertBasis(inputPrefix + ".out");

    // Step 5: Write M2-readable output
    writeMacaulay2File(hilbertBasis, finalM2);

    // Step 6: Remove temp files
    cleanupTempFiles(inputPrefix);

    return 0;
}
