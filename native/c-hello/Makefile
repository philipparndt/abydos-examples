CFLAGS ?= -g -O0 -Wall -Wextra
BIN    := build/c-hello

.PHONY: build run clean
build: ## Build with debug information
	@mkdir -p build
	$(CC) $(CFLAGS) -o $(BIN) src/main.c

run: build ## Build and run
	./$(BIN)

clean:
	rm -rf build
