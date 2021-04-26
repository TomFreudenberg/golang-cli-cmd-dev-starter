# From https://github.com/TomFreudenberg/golang-cli-cmd-dev-starter
# Copyright © 2021 Tom Freudenberg

all: cmd-all


# define a number of vars from environment

# current working path and directory
PWD := $(shell pwd)
DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))

# prepare GO environment
GOENV := ${DIR}/go.env
GOPATH := ${DIR}/.go
GOTOOLS := ${GOPATH}/bin
GOGLOBTESTDATA := ${DIR}/data/testdata

# define the target OS/ARCH to compile for
GOOS_DEFAULT=$(shell uname -s | tr '[:upper:]' '[:lower:]')
GOARCH_DEFAULT=amd64
ifeq ($(strip $(GOOS)),)
GOOS := ${GOOS_DEFAULT}
endif
ifeq ($(strip $(GOARCH)),)
GOARCH := ${GOARCH_DEFAULT}
endif

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



# Macro to clean up environment
.PHONY: clean
clean:
	@find ${GOPATH} -type d -exec chmod 755 "{}" \;
	@rm -rf ${GOPATH}
	@rm -rf ${DIR}/tmp/*



# Macro to prepare and check go environment
.PHONY: go-prepare
go-prepare:
	@mkdir -p ${GOPATH}
	@touch ${GOENV}



# Macro to prepare and check go environment
.PHONY: go-mod
go-mod:
	@make go ARGS="mod tidy"



# Macro to install the go tools needed for development
.PHONY: go-tools
go-tools:
	@make go-prepare
	@GOENV=${GOENV} GOPATH=${GOPATH} go install -modcacherw golang.org/x/lint/golint@latest
	@GOENV=${GOENV} GOPATH=${GOPATH} go install -modcacherw golang.org/x/tools/cmd/godoc@latest
	@cd /tmp && \
	 git clone -b stable-featured --depth=1 https://github.com/TomFreudenberg/golang-tools.git && \
	 cd golang-tools && \
	 GOPATH=/tmp/golang-tools/.go go build -modcacherw -o ${GOPATH}/bin/godoc golang.org/x/tools/cmd/godoc && \
	 cd /tmp && \
	 rm -rf golang-tools



# Macro to run go
.PHONY: go
go:
	@if [ "$(strip $(ARGS))" != "" ]; then \
		make go-drive; \
	else \
		echo "Please use ARGS=arguments to run go command"; \
		exit 1; \
	fi

go-drive:
	@make go-prepare
	@cd src && \
		GOENV=${GOENV} GOPATH=${GOPATH} GOOS=${GOOS} GOARCH=${GOARCH} \
		go \
			${ARGS}



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

# Test where to place the binaries
BIN_TARGET := bin/$(GOOS)/$(GOARCH)/
ifeq ($(GOOS)/$(GOARCH),$(GOOS_DEFAULT)/$(GOARCH_DEFAULT))
BIN_TARGET := bin/
endif

cmd-build:
	@echo "Spinning cmd-building: ${PKG} into ./${BIN_TARGET}"
	@make go-prepare
	@echo "Build for target architecture: ${GOOS}/${GOARCH}\n"
	@mkdir -p ./${BIN_TARGET}
	@cd src && \
		GOENV=${GOENV} GOPATH=${GOPATH} GOOS=${GOOS} GOARCH=${GOARCH} \
		go build \
			-modcacherw \
			-o ../${BIN_TARGET} \
			${PKG}



# Macro to build a single command from this project
.PHONY: run
run:
	@if [ "$(strip $(CMD))" != "" ]; then \
		make run-cmd CMD="" PKG=${GO_MODULE}/cmd/${CMD}/; \
	else \
		echo "Please use CMD=command to run command"; \
		exit 1; \
	fi

run-cmd:
	@echo "Spinning cmd-run: ${PKG}"
	@make go-prepare
	@echo "Running on target architecture: ${GOOS}/${GOARCH}\n"
	@cd src && \
		GOENV=${GOENV} GOPATH=${GOPATH} GOOS=${GOOS} GOARCH=${GOARCH} \
		go run \
			-modcacherw \
			${PKG} \
			${ARGS}



# Macro to run all tests from this app
.PHONY: test-all
test-all:
	@make test-drive FILES="" CMD="" PKG="${GO_MODULE}/..." TAGS=unit,integration,extra RUN=""

# Macro to run a single command or package test
.PHONY: test
test:
	@if [ "$(strip $(FILES))" != "" ]; then \
		make test-drive CMD="" PKG=""; \
	elif  [ "$(strip $(CMD))" != "" ]; then \
		make test-drive CMD="" PKG=${GO_MODULE}/cmd/${CMD}/...; \
	elif [ "$(strip $(PKG))" != "" ]; then \
		make test-drive PKG=${GO_MODULE}/${PKG}; \
	else \
		echo "Please use FILES=files/filemask or CMD=command or PKG=component-path/... to run testing or use 'make test-all'"; \
		exit 1; \
	fi

ifneq ($(strip $(FILES)),)
TEST_FILES := $(shell cd src && ls $(FILES) | sort --unique)
endif

# Test if need to set some tags for testing
ifeq ($(strip $(TAGS)),)
TEST_TAGS_FLAG :=
TEST_TAGS :=
else
TEST_TAGS_FLAG := -tags
TEST_TAGS := "${TAGS}"
endif

# Test if need to set some tags for testing
ifeq ($(strip $(FILTER)),)
TEST_FILTER_FLAG :=
TEST_FILTER :=
else
TEST_FILTER_FLAG := -test.run
TEST_FILTER := "$(FILTER)"
endif

test-drive:
	@echo "Spinning up testing: ${PKG}\n"
	@make go-prepare
	@cd src && \
		GOENV=${GOENV} GOPATH=${GOPATH} GOGLOBTESTDATA=${GOGLOBTESTDATA} \
		go test \
			-modcacherw -count=1 -timeout=60s \
			${DEBUG_VERBOSE_FLAG} \
			${TEST_TAGS_FLAG} ${TEST_TAGS} \
			${TEST_FILES} \
			${PKG} \
			${TEST_FILTER_FLAG} ${TEST_FILTER}



# Macro to run all benchmarkings from this app
.PHONY: bench-all
bench-all:
	@make bench-drive FILES="" CMD="" PKG="${GO_MODULE}/..." TAGS=unit,integration,extra RUN=""

# Macro to run a single command or package bench
.PHONY: bench
bench:
	@if [ "$(strip $(FILES))" != "" ]; then \
		make bench-drive CMD="" PKG=""; \
	elif  [ "$(strip $(CMD))" != "" ]; then \
		make bench-drive CMD="" PKG=${GO_MODULE}/cmd/${CMD}/...; \
	elif [ "$(strip $(PKG))" != "" ]; then \
		make bench-drive PKG=${GO_MODULE}/${PKG}; \
	else \
		echo "Please use FILES=files/filemask or CMD=command or PKG=component-path/... to run benchmarking or use 'make bench-all'"; \
		exit 1; \
	fi

ifneq ($(strip $(FILES)),)
BENCH_FILES := $(shell cd src && ls $(FILES) | sort --unique)
endif

# Test if need to set some tags for benchmarking
ifeq ($(strip $(TAGS)),)
BENCH_TAGS_FLAG :=
BENCH_TAGS :=
else
BENCH_TAGS_FLAG := -tags
BENCH_TAGS := "${TAGS}"
endif

# Test if need to set some filter for benchmarking
ifeq ($(strip $(FILTER)),)
BENCH_FILTER_FLAG := -bench
BENCH_FILTER := .
else
BENCH_FILTER_FLAG := -bench
BENCH_FILTER := "$(FILTER)"
endif

# Test if need to set another runtime for benchmarking
ifeq ($(strip $(BENCH_TIME)),)
BENCH_TIME := 5
else
BENCH_TIME := "$(BENCH_TIME)"
endif

# Test if need to set another cpu usage for benchmarking
ifeq ($(strip $(BENCH_CPU)),)
BENCH_CPU := 1
else
BENCH_CPU := "$(BENCH_CPU)"
endif

# Test if need to set an output file for benchmarking
ifeq ($(strip $(BENCH_OUT)),)
BENCH_OUT_FLAG :=
BENCH_OUT_FILE :=
else
BENCH_OUT_FLAG := -cpuprofile
BENCH_OUT_FILE := "$(BENCH_OUT)"
endif

bench-drive:
	@echo "Spinning up benchmarking: ${PKG}\n"
	@make go-prepare
	@cd src && \
		GOENV=${GOENV} GOPATH=${GOPATH} GOGLOBTESTDATA=${GOGLOBTESTDATA} \
		go test \
			-modcacherw -count=1 -timeout=60s \
			-test.run DoNotRunAnyTestButBenchmark \
			${BENCH_OUT_FLAG} ${BENCH_OUT_FILE} \
			${BENCH_TAGS_FLAG} ${BENCH_TAGS} \
			${BENCH_FILES} \
			${PKG} \
			${BENCH_FILTER_FLAG} ${BENCH_FILTER} \
			-benchtime ${BENCH_TIME}s \
			-cpu ${BENCH_CPU}



# Macro to run the formatter
.PHONY: fmt-all
fmt-all:
	@make fmt-drive PKG="cmd internal"

.PHONY: fmt
fmt:
	@if  [ "$(strip $(CMD))" != "" ]; then \
		make fmt-drive CMD="" PKG=cmd/${CMD}/; \
	elif [ "$(strip $(PKG))" != "" ]; then \
		make fmt-drive; \
	else \
		echo "Please use CMD=command or PKG=component-path to run gofmt or use 'make fmt-all'"; \
		exit 1; \
	fi

# Test if need to set some flags for formatting
ifeq ($(strip $(DIFF)),)
FMT_DIFF_FLAG :=
FMT_LIST_FLAG := "-l"
else
FMT_DIFF_FLAG := "-d"
FMT_LIST_FLAG :=
endif

# Test if need to set write flag for formatting
ifeq ($(strip $(OVERWRITE)),)
FMT_WRITE_FLAG :=
else
FMT_WRITE_FLAG := "-w"
FMT_LIST_FLAG := "-l"
FMT_DIFF_FLAG :=
endif

fmt-drive:
	@echo "Spinning formatting: ${GO_MODULE} [ ${PKG} ]\n"
	@make go-prepare
	@if [ "$(strip $(FMT_WRITE_FLAG))" != "" ]; then \
		echo "Listed files are updated while having OVERWRITE=1\n"; \
	else \
		echo "Listed files won\`t be changed without having OVERWRITE=1\n"; \
	fi
	@cd src && \
		GOENV=${GOENV} GOPATH=${GOPATH} \
		gofmt \
			${FMT_WRITE_FLAG} \
			${FMT_DIFF_FLAG} \
			${FMT_LIST_FLAG} \
			-e ${PKG}



# Macro to run the linter
.PHONY: lint
lint-all:
	@make lint-drive PKG="cmd/... internal/..."

.PHONY: lint
lint:
	@if  [ "$(strip $(CMD))" != "" ]; then \
		make lint-drive CMD="" PKG=cmd/${CMD}/...; \
	elif [ "$(strip $(PKG))" != "" ]; then \
		make lint-drive; \
	else \
		echo "Please use CMD=command or PKG=component-path/... to run linting or use 'make lint-all'"; \
		exit 1; \
	fi

lint-drive:
	@echo "Spinning up linting: ${GO_MODULE} [ ${PKG} ]\n"
	@make go-prepare
	@cd src && \
		GOENV=${GOENV} GOPATH=${GOPATH} \
		${GOTOOLS}/golint \
			-set_exit_status \
			${PKG}



# Macro to run a godoc instance for this project
.PHONY: godoc
godoc: | godoc-serve

godoc-serve:
	@echo "Serving godoc on http://localhost:${GODOC_PORT}"
	@cd src && \
		GOENV=${GOENV} GOPATH=${GOPATH} \
		${GOTOOLS}/godoc \
			-goroot ${DIR} \
			-templates ${DIR}/doc/templates \
			-index \
			-show_internal_pkg \
			-http=:${GODOC_PORT} \
			2>/dev/null


