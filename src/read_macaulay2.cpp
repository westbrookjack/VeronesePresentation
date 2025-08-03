#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>
#include <string>
#include <cstdio>    // for std::remove
#include "read_macaulay2.h"

// Trim whitespace from both ends of a string
std::string trim(const std::string& s) {
    size_t start = s.find_first_not_of(" \t\n\r");
    size_t end = s.find_last_not_of(" \t\n\r");
    return (start == std::string::npos) ? "" : s.substr(start, end - start + 1);
}

// Parse a string like "{1,2,3}" into a vector<int>
std::vector<int> parseList(const std::string& listStr) {
    std::vector<int> result;

    size_t closingBrace = listStr.find('}');
    if (closingBrace == std::string::npos || listStr[0] != '{') {
        std::cerr << "Malformed list string: " << listStr << "\n";
        return result;
    }

    std::string inner = listStr.substr(1, closingBrace - 1);
    std::istringstream iss(inner);
    std::string token;
    while (getline(iss, token, ',')) {
        std::string cleaned = trim(token);

        // Strip trailing non-digit chars
        cleaned.erase(std::find_if(cleaned.rbegin(), cleaned.rend(),
            [](char ch) { return std::isdigit(ch); }).base(), cleaned.end());

        try {
            if (!cleaned.empty()) {
                result.push_back(std::stoi(cleaned));
            } else {
                std::cerr << "Warning: encountered empty/invalid token in list: [" << token << "]\n";
            }
        } catch (const std::exception& e) {
            std::cerr << "Error parsing list element: " << token << " (" << e.what() << ")\n";
            exit(1);
        }
    }

    return result;
}


// Read a file of the form {{1,2,3}, 5}
void readMacaulay2Input(const std::string& filename, std::vector<int>& myList, int& n) {
    std::ifstream in(filename);
    if (!in.is_open()) {
        std::cerr << "Failed to open file.\n";
        return;
    }

    std::string line;
    if (!getline(in, line)) {
        std::cerr << "Failed to read from file.\n";
        return;
    }
    in.close();

    line = trim(line);

    // Step 1: Extract the inner list
    size_t outerFirst = line.find('{');
    size_t innerStart = line.find('{', outerFirst + 1);       // second '{'
    size_t innerEnd = line.find('}', innerStart);             // first '}' after innerStart

    if (innerStart == std::string::npos || innerEnd == std::string::npos || innerEnd <= innerStart) {
        std::cerr << "Malformed input: couldn't isolate inner list.\n";
        return;
    }

    std::string listStr = line.substr(innerStart, innerEnd - innerStart + 1);
    myList = parseList(listStr);

    // Step 2: Extract the integer after the inner list
    size_t commaPos = line.find(',', innerEnd);
    if (commaPos == std::string::npos) {
        std::cerr << "Malformed input: missing comma before integer.\n";
        return;
    }

    std::string intPart = line.substr(commaPos + 1);
    std::string trimmed = trim(intPart);

    // Strip trailing non-digit characters
    trimmed.erase(std::find_if(trimmed.rbegin(), trimmed.rend(),
        [](char ch) { return std::isdigit(ch); }).base(), trimmed.end());

    try {
        if (trimmed.empty()) {
            throw std::invalid_argument("Empty integer string after trimming.");
        }
        n = std::stoi(trimmed);
    } catch (const std::exception& e) {
        std::cerr << "Error: could not convert to int: " << e.what() << "\n";
        exit(1);
    }

    // Step 3: Delete the file after reading
    std::remove(filename.c_str());

}