BIN := build/odin-hello

.PHONY: build run test clean
build: ## Build with debug information
	@mkdir -p build
	odin build src -out:$(BIN) -debug

run: ## Build and run
	@mkdir -p build
	odin run src -out:$(BIN) -debug

test: ## Run whatever the package checks
	odin check src

clean:
	rm -rf build
