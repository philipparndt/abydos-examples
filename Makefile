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
	@cd go-service && go build -o build/go-service .
	@cd smart-home-microservice && go build -o build/smart-home-microservice .
	@cd multi-tier && go build -o build/app ./app && go build -o build/web ./web
	@cd native/odin-hello && $(MAKE) -s build
	@cd native/zig-hello && zig build
	@cd native/rust-hello && cargo build -q
	@cd native/c-hello && $(MAKE) -s build
	@cd native/cpp-hello && $(MAKE) -s build
	@$(MAKE) -s java
	@echo "==> everything builds"

# Its own goal, because these two are the only examples that reach the network
# to build: Maven and Gradle fetch their own plugins the first time, and a
# `make build` that fails on a train should say which half it was.
.PHONY: java
java: ## Build the Java examples (needs a JDK, and the network once)
	@cd java/maven-service && mvn -q -B package -DskipTests
	@cd java/gradle-service && gradle -q --console=plain assemble

.PHONY: charts
charts: ## Check the charts
	@helm lint multi-tier/deploy/chart --values multi-tier/deploy/values-dev.yaml

.PHONY: clean
clean: ## Remove everything built and generated
	@rm -rf git-scenarios/out */build native/*/build native/zig-hello/zig-out \
		native/zig-hello/.zig-cache native/rust-hello/target \
		java/maven-service/target java/gradle-service/build java/gradle-service/.gradle
	@cd go-service && go clean
	@echo "==> cleaned"
