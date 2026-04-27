GO ?= go
DIST_DIR := dist
SRC_ROOT := $(shell git rev-parse --show-toplevel)
TOOLS_MOD_DIR := $(SRC_ROOT)/internal/tools
TOOLS_MOD_FILE := $(TOOLS_MOD_DIR)/go.mod
GO_TOOL := $(GO) tool -modfile $(TOOLS_MOD_FILE)

.PHONY: build
build:
	$(GO) build -o $(DIST_DIR)/kubectl-view_serviceaccount_kubeconfig cmd/kubectl-view_serviceaccount_kubeconfig.go

.PHONY: build-cross
build-cross:
	$(GO_TOOL) goreleaser build --snapshot --clean

.PHONY: lint
lint:
	$(GO_TOOL) golangci-lint run

.PHONY: lint-fix
lint-fix:
	$(GO_TOOL) golangci-lint run --fix

.PHONY: test
test:
	$(GO) test -v ./...

.PHONY: validate-krew-manifest
validate-krew-manifest:
	$(GO_TOOL) validate-krew-manifest -manifest dist/krew/view-serviceaccount-kubeconfig.yaml -skip-install

.PHONY: dist
dist:
	cat .goreleaser.yaml | \
		$(GO_TOOL) goreleaser-filter -goos $(shell go env GOOS) -goarch $(shell go env GOARCH) | \
		$(GO_TOOL) goreleaser release -f- --clean --skip=publish --snapshot

.PHONY: dist-all
dist-all:
	$(GO_TOOL) goreleaser release --clean --skip=publish --snapshot

.PHONY: release
release:
	$(GO_TOOL) goreleaser release --clean --skip=publish

.PHONY: clean
clean:
	rm -rf $(DIST_DIR)
