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
	@$(MAKE) -s models
	@echo "==> everything builds"

# Its own goal, because these two are the only examples that reach the network
# to build: Maven and Gradle fetch their own plugins the first time, and a
# `make build` that fails on a train should say which half it was.
.PHONY: java
java: ## Build the Java examples (needs a JDK, and the network once)
	@cd java/maven-service && mvn -q -B package -DskipTests
	@cd java/hot-swap && mvn -q -B package -DskipTests
	@cd java/gradle-service && gradle -q --console=plain assemble

# The third of those, and the slowest: seven packages to fetch and a C++
# geometry kernel to compile, 23 s and 65 s the first time and seconds after.
#
# `xcrun swift` rather than `swift`, for the reason the app's own Makefile
# gives: a toolchain manager puts its own `swift` in front, and this manifest
# is `swift-tools-version: 6.3`. `-j 4` because a machine building this is
# usually building something else too.
.PHONY: models
models: ## Build the Cadova example (needs Swift 6.3, and the network once)
	@cd cadova-models && xcrun swift build -j 4
	@cd cadova-models && xcrun swift run -j 4 hex-key-holder
	@cd cadova-models && xcrun swift run -j 4 coaster

.PHONY: diagrams
diagrams: ## Draw the diagrams (needs docker, or Apple's container)
	@./plantuml/draw.sh

.PHONY: charts
charts: ## Check the charts
	@helm lint multi-tier/deploy/chart --values multi-tier/deploy/values-dev.yaml

.PHONY: clean
clean: ## Remove everything built and generated
	@rm -rf git-scenarios/out */build native/*/build native/zig-hello/zig-out \
		native/zig-hello/.zig-cache native/rust-hello/target \
		java/maven-service/target java/hot-swap/target \
		java/gradle-service/build java/gradle-service/.gradle \
		cadova-models/.build cadova-models/Models
	@cd go-service && go clean
	@echo "==> cleaned"
