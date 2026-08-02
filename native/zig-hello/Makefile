.PHONY: build run clean
build: ## Build the debug binary
	zig build

run: build ## Build and run
	./zig-out/bin/zig-hello

clean:
	rm -rf zig-out .zig-cache
