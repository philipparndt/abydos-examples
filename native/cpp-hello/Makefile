CXXFLAGS ?= -g -O0 -std=c++20 -Wall -Wextra
BIN      := build/cpp-hello

.PHONY: build run clean
build: ## Build with debug information
	@mkdir -p build
	$(CXX) $(CXXFLAGS) -o $(BIN) src/main.cpp

run: build ## Build and run
	./$(BIN)

clean:
	rm -rf build
