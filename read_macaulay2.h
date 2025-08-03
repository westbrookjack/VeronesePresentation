#ifndef READ_AND_CLEANUP_H
#define READ_AND_CLEANUP_H

#include <string>
#include <vector>

std::string trim(const std::string& s);
std::vector<int> parseList(const std::string& listStr);
void readMacaulay2Input(const std::string& filename, std::vector<int>& myList, int& n);

#endif
