// Small enough to read, with something worth stepping through: a container, an
// algorithm, and a lambda that captures.
#include <algorithm>
#include <iostream>
#include <string>
#include <vector>

struct Reading {
	std::string sensor;
	double celsius;
};

std::vector<Reading> readings() {
	std::vector<Reading> out;
	for (int i = 1; i <= 5; ++i) {
		out.push_back({"sensor-" + std::to_string(i), 18.0 + i * 1.5});
	}
	return out;
}

int main() {
	auto values = readings();
	for (const auto &reading : values) {
		std::cout << reading.sensor << " is at " << reading.celsius << "C\n";
	}

	auto warmest = std::max_element(
		values.begin(), values.end(),
		[](const Reading &a, const Reading &b) { return a.celsius < b.celsius; });
	std::cout << "warmest: " << warmest->sensor << "\n";
	return 0;
}
