# The examples, built and checked the way somebody would use them.

.DEFAULT_GOAL := help

.PHONY: help
help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}'

.PHONY: scenarios
scenarios: ## Make the git repositories in git-scenarios/out
	@./git-scenarios/make-scenarios.sh

.PHONY: build
build: ## Build every example that has a build
	@cd go-service && go build ./...
	@cd lamarzocco-style && go build ./...
	@cd multi-tier && go build ./...
	@cd native/zig-hello && zig build
	@cd native/rust-hello && cargo build -q
	@cd native/c-hello && $(MAKE) -s build
	@cd native/cpp-hello && $(MAKE) -s build
	@echo "==> everything builds"

.PHONY: charts
charts: ## Check the charts
	@helm lint multi-tier/deploy/chart --values multi-tier/deploy/values-dev.yaml

.PHONY: clean
clean: ## Remove everything built and generated
	@rm -rf git-scenarios/out native/*/build native/zig-hello/zig-out \
		native/zig-hello/.zig-cache native/rust-hello/target
	@cd go-service && go clean
	@echo "==> cleaned"
