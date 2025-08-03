#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <cstdlib>
#include "generate_input_file.h"


// Writes the Normaliz input file with input a vector of positive integers and a positive integer n.
void generateInputFile(const std::vector<int>& myList, int n, const std::string& filename) {
    std::ofstream out(filename);
    int r = myList.size();

    out << "amb_space " << r << "\n";
    out << "inhom_congruences 1\n";
    for (int i = 0; i < r; ++i) out << myList[i] << " ";
    out << "0 "<<n << "\n";
    out.close();
}