#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>
#include <string>
#include "parseHilbertBasis.h"

std::vector<int> splitLineToInts(const std::string& line) {
    std::istringstream iss(line);
    std::vector<int> result;
    int val;
    while (iss >> val) result.push_back(val);
    return result;
}

//This function takes as input the filename of a Normaliz output file
//and extracts the Hilbert basis elements from it.
std::vector<std::vector<int>> extractHilbertBasis(const std::string& filename) {
    std::ifstream in(filename);
    std::string line;
    std::vector<std::vector<int>> basis;

    bool inHilbertSection = false;
    while (getline(in, line)) {
        if (!inHilbertSection) {
            if (line.find("Hilbert basis elements of recession monoid:") != std::string::npos) {
                inHilbertSection = true;
                continue;
            }
        } else {
            if (line.empty() || line.find_first_not_of(" \t0123456789") != std::string::npos) break;

            std::vector<int> vec = splitLineToInts(line);
            if (!vec.empty() && vec.back() == 0) {
                vec.pop_back();  // drop last coord
                basis.push_back(vec);
            }
        }
    }

    in.close();
    return basis;
}