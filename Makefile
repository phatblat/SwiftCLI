#
# Makefile
# SwiftCLI
#

################################################################################
#
# Variables
#

CMD_NAME = swiftcli
SHELL = /bin/sh

SWIFT_VERSION = ${shell cat .swift-version}

# set EXECUTABLE_DIRECTORY according to your specific environment
# run swift build and see where the output executable is created

# OS specific differences
UNAME = ${shell uname}

ifeq ($(UNAME), Darwin)
	SWIFTC_FLAGS =
	LINKER_FLAGS = -Xlinker -L/usr/local/lib
	PLATFORM = x86_64-apple-macosx
	EXECUTABLE_DIRECTORY = ./.build/${PLATFORM}/debug
	TEST_BUNDLE = ${CMD_NAME}PackageTests.xctest
	TEST_RESOURCES_DIRECTORY = ./.build/${PLATFORM}/debug/${TEST_BUNDLE}/Contents/Resources
endif
ifeq ($(UNAME), Linux)
	SWIFTC_FLAGS = -Xcc -fblocks
	LINKER_FLAGS = -Xlinker -rpath -Xlinker .build/debug
	PATH_TO_SWIFT = /home/vagrant/swiftenv/versions/$(SWIFT_VERSION)
	PLATFORM = x86_64-unknown-linux
	EXECUTABLE_DIRECTORY = ./.build/${PLATFORM}/debug
	TEST_RESOURCES_DIRECTORY = ${EXECUTABLE_DIRECTORY}
endif

RUN_RESOURCES_DIRECTORY = ${EXECUTABLE_DIRECTORY}

################################################################################
#
# Help
#

.DEFAULT_GOAL := help

.PHONY: help
help: MAKEFILE_FMT = "  \033[36m%-25s\033[0m%s\n"
help: ## (default) Displays this message
	@echo "SwiftCLI Makefile"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z0-9_-]*:.*?##' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?##"}; {printf $(MAKEFILE_FMT), $$1, $$2}'
	@echo ""
	@echo "Parameters:"
	@grep -E '^[A-Z0-9_-]* ?\?=.*?##' $(MAKEFILE_LIST) | awk 'BEGIN {FS = " ?\\?=.*?##"}; {printf $(MAKEFILE_FMT), $$1, $$2}'
: # Hacky way to display a newline ##

################################################################################
#
# Targets
#

.PHONY: version
version: ## Shows versions of tools
	xcodebuild -version
	swift --version
	swift package tools-version

.PHONY: init
init: ## Installs required tools
	- swiftenv install $(SWIFT_VERSION)
	swiftenv local $(SWIFT_VERSION)
ifeq ($(UNAME), Linux)
	cd /vagrant && \
	git clone --recursive -b experimental/foundation https://github.com/apple/swift-corelibs-libdispatch.git && \
	cd swift-corelibs-libdispatch && \
	sh ./autogen.sh && \
	./configure --with-swift-toolchain=/home/vagrant/swiftenv/versions/$(SWIFT_VERSION)/usr \
		--prefix=/home/vagrant/swiftenv/versions/$(SWIFT_VERSION)/usr && \
	make && make install
endif

.PHONY: clean
clean: ## Cleans build folders
	swift package clean
	swift package reset

.PHONY: describe
describe: ## Shows the package description
	swift package describe

.PHONY: resolve
resolve: ## Installs package dependencies
	swift package resolve

.PHONY: dependencies
dependencies: resolve ##  Show package depencencies
	swift package show-dependencies

.PHONY: update
update: resolve ## Updates dependencies
	swift package update

.PHONY: build
build: copyRunResources ## Builds the package
	swift build $(SWIFTC_FLAGS) $(LINKER_FLAGS)

.PHONY: test
test: build copyTestResources ## Tests the package
	swift test --enable-test-discovery

.PHONY: copyRunResources
copyRunResources: ## Copies runtime resources
	mkdir -p ${RUN_RESOURCES_DIRECTORY}
	cp -r Resources/* ${RUN_RESOURCES_DIRECTORY}

.PHONY: copyTestResources
copyTestResources:## Copies test resources
	mkdir -p ${TEST_RESOURCES_DIRECTORY}
	cp -r Resources/* ${TEST_RESOURCES_DIRECTORY}

.PHONY: run
# make run ARGS="asdf"
run: build ## Runs the project executible
	${EXECUTABLE_DIRECTORY}/${CMD_NAME} $(ARGS)
