# https://github.com/TomFreudenberg/golang-cli-cmd-dev-starter
# (C)2021 Tom Freudenberg

all: cmd-all


# define a number of vars from environment

# define the target OS/ARCH to compile for
GOOS_DEFAULT=$(shell uname -s | tr '[:upper:]' '[:lower:]')
GOARCH_DEFAULT=amd64
ifeq ($(strip $(GOOS)),)
GOOS := ${GOOS_DEFAULT}
endif
ifeq ($(strip $(GOARCH)),)
GOARCH := ${GOARCH_DEFAULT}
endif

# current working path
PWD := $(shell pwd)

# Port to run godoc server on
GODOC_PORT := 6060

# Read the name of the module for this project
GO_MODULE := $(shell cat src/go.mod | egrep '^module' | head -n 1 | sed -e 's/^module[[:space:]]\{1,\}//')

# Find all commands inside this project
GO_MODULE_CMD_LIST := $(shell cd src/cmd && find . -type d -mindepth 1 -maxdepth 1 | sed -e 's/^\.\///g')

# Test if need verbosity on some commands
ifeq ($(strip $(DEBUG)), 1)
DEBUG_VERBOSE_FLAG := -v
else
DEBUG_VERBOSE_FLAG :=
endif



# Macro to build all commands inside this project
.PHONY: cmd-all
cmd-all:
	@echo "Build all commands: [ $(GO_MODULE_CMD_LIST) ]"
	@make cmd-build PKG=${GO_MODULE}/cmd/...

# Macro to build a single command from this project
.PHONY: cmd
cmd:
	@if [ "$(strip $(CMD))" != "" ]; then \
		make cmd-build CMD="" PKG=${GO_MODULE}/cmd/${CMD}/; \
	else \
		echo "Please use CMD=command to run build or use 'make cmd-all'"; \
		exit 1; \
	fi

cmd-build:
	@echo "Prepare docker image for cmd-build ..."
	@make cmd-build-drive LAST_BUILD_GOBUILD_IMAGE_ID=$$(docker build . --target gobuild -q | head -n 1)

# Test where to place the binaries
BIN_TARGET := bin/$(GOOS)/$(GOARCH)/
ifeq ($(GOOS)/$(GOARCH),$(GOOS_DEFAULT)/$(GOARCH_DEFAULT))
BIN_TARGET := bin/
endif

cmd-build-drive:
	@echo "Spinning up docker image cmd-building: ${PKG} into ./${BIN_TARGET}"
	@echo "Build for target architecture: ${GOOS}/${GOARCH}\n"
	@mkdir -p ./${BIN_TARGET}
	@docker run --rm -it \
		--mount type=bind,src=${PWD}/bin,dst=/app/bin \
		--mount type=bind,src=${PWD}/src,dst=/app/src \
		--env GOOS=${GOOS} \
		--env GOARCH=${GOARCH} \
		${LAST_BUILD_GOBUILD_IMAGE_ID} \
		go build -o /app/${BIN_TARGET} ${PKG}



# Macro to run all tests from this app
.PHONY: test-all
test-all:
	@make test-build CMD="" PKG="${GO_MODULE}/..." TAGS=unit,integration,extra RUN=""

# Macro to run a single command or package test
.PHONY: test
test:
	@if  [ "$(strip $(CMD))" != "" ]; then \
		make test-build CMD="" PKG=${GO_MODULE}/cmd/${CMD}/...; \
	elif [ "$(strip $(PKG))" != "" ]; then \
		make test-build PKG=${GO_MODULE}/${PKG}; \
	else \
		echo "Please use CMD=command or PKG=component-path/... to run testing or use 'make test-all'"; \
		exit 1; \
	fi

test-build:
	@echo "Prepare docker image for testing ..."
	@make test-drive LAST_BUILD_TEST_IMAGE_ID=$$(docker build . --target unit-test -q | head -n 1)

# Test if need to set some tags for testing
ifeq ($(strip $(TAGS)),)
TEST_TAGS_FLAG :=
TEST_TAGS :=
else
TEST_TAGS_FLAG := -tags
TEST_TAGS := "${TAGS}"
endif

# Test if need to set some tags for testing
ifeq ($(strip $(RUN)),)
TEST_RUN_FLAG :=
TEST_RUN :=
else
TEST_RUN_FLAG := -test.run
TEST_RUN := "$(RUN)"
endif

test-drive:
	@echo "Spinning up docker image testing: ${PKG}\n"
	@docker run --rm -it \
		--mount type=bind,src=${PWD}/src,dst=/app/src \
		${LAST_BUILD_TEST_IMAGE_ID} \
		go test -count=1 -timeout=60s ${DEBUG_VERBOSE_FLAG} ${TEST_TAGS_FLAG} ${TEST_TAGS} ${PKG} ${TEST_RUN_FLAG} ${TEST_RUN}



# Marco to run the formatter
.PHONY: fmt-all
fmt-all:
	@make fmt-build PKG="cmd internal"

.PHONY: fmt
fmt:
	@if  [ "$(strip $(CMD))" != "" ]; then \
		make fmt-build CMD="" PKG=cmd/${CMD}/; \
	elif [ "$(strip $(PKG))" != "" ]; then \
		make fmt-build; \
	else \
		echo "Please use CMD=command or PKG=component-path to run gofmt or use 'make fmt-all'"; \
		exit 1; \
	fi

fmt-build:
	@echo "Prepare docker image for formatting ..."
	@make fmt-drive LAST_BUILD_LINT_IMAGE_ID=$$(docker build . --target lint -q | head -n 1);

# Test if need to set some flags for formatting
ifeq ($(strip $(DIFF)),)
FMT_DIFF_FLAG :=
FMT_LIST_FLAG := "-l"
else
FMT_DIFF_FLAG := "-d"
FMT_LIST_FLAG :=
endif

ifeq ($(strip $(OVERWRITE)),)
FMT_WRITE_FLAG :=
else
FMT_WRITE_FLAG := "-w"
FMT_LIST_FLAG := "-l"
FMT_DIFF_FLAG :=
endif

fmt-drive:
	@echo "Spinning up docker image formatting: ${GO_MODULE} [ ${PKG} ]\n"
	@if [ "$(strip $(FMT_WRITE_FLAG))" != "" ]; then \
		echo "Listed files are updated while having OVERWRITE=1\n"; \
	else \
		echo "Listed files won\`t be changed without having OVERWRITE=1\n"; \
	fi
	@docker run --rm -it \
		--mount type=bind,src=${PWD}/src,dst=/app/src \
		${LAST_BUILD_LINT_IMAGE_ID} \
		gofmt ${FMT_WRITE_FLAG} ${FMT_DIFF_FLAG} ${FMT_LIST_FLAG} -e ${PKG}



# Marco to run the linter
.PHONY: lint
lint-all:
	@make lint-build PKG="cmd/... internal/..."

.PHONY: lint
lint:
	@if  [ "$(strip $(CMD))" != "" ]; then \
		make lint-build CMD="" PKG=cmd/${CMD}/...; \
	elif [ "$(strip $(PKG))" != "" ]; then \
		make lint-build; \
	else \
		echo "Please use CMD=command or PKG=component-path/... to run linting or use 'make lint-all'"; \
		exit 1; \
	fi

lint-build:
	@echo "Prepare docker image for linting ..."
	@make lint-drive LAST_BUILD_LINT_IMAGE_ID=$$(docker build . --target lint -q | head -n 1);

lint-drive:
	@echo "Spinning up docker image linting: ${GO_MODULE} [ ${PKG} ]\n"
	@docker run --rm -it \
		--mount type=bind,src=${PWD}/src,dst=/app/src \
		${LAST_BUILD_LINT_IMAGE_ID} \
		golint -set_exit_status ${PKG}



# Macro to run a godoc instance for this project
.PHONY: godoc
godoc: | godoc-build

godoc-build:
	@docker build . --target godoc
	@make godoc-serve LAST_BUILD_GODOC_IMAGE_ID=$$(docker build . --target godoc -q | head -n 1)

godoc-serve:
	@echo "Serving godoc on http://localhost:${GODOC_PORT}"
	@docker run --rm -it -p 6060:6060 \
		--mount type=bind,src=${PWD}/doc,dst=/app/doc \
		--mount type=bind,src=${PWD}/src,dst=/app/src \
		${LAST_BUILD_GODOC_IMAGE_ID} \
		godoc -goroot /app -templates /app/doc/templates -index -show_internal_pkg -http=:${GODOC_PORT} 2>/dev/null



# Macro to run an interactive go shell
.PHONY: shell
shell: | shell-build

shell-build:
	@echo "Prepare docker image for shell ..."
	@make shell-serve LAST_BUILD_GOBUILD_IMAGE_ID=$$(docker build . --target gobuild -q | head -n 1)

shell-serve:
	@echo "Running shell on intance ..."
	@echo "Go build binaries for target architecture: ${GOOS}/${GOARCH}\n"
	@docker run --rm -it -p 6061:6060 \
		--mount type=bind,src=${PWD}/bin,dst=/app/bin \
		--mount type=bind,src=${PWD}/doc,dst=/app/doc \
		--mount type=bind,src=${PWD}/src,dst=/app/src \
		--env GOOS=${GOOS} \
		--env GOARCH=${GOARCH} \
		${LAST_BUILD_GOBUILD_IMAGE_ID} \
		/bin/sh


