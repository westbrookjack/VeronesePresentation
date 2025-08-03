#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include "write_macaulay2.h"


void writeMacaulay2File(const std::vector<std::vector<int>>& data, const std::string& filename) {
    std::ofstream out(filename);

    out << "{";
    for (size_t i = 0; i < data.size(); ++i) {
        out << "{";
        for (size_t j = 0; j < data[i].size(); ++j) {
            out << data[i][j];
            if (j + 1 < data[i].size()) out << ", ";
        }
        out << "}";
        if (i + 1 < data.size()) out << ", ";
    }
    out << "}\n";

    out.close();
}
