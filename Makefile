PROJECT_DIR := $(PWD)
PROJECT_NAME := $(shell grep '^name:' project.yml | sed 's/^name: //')
TEST_DEVICE = $(shell grep '^test_device:' .actions.yml | sed 's/^test_device: //')
ECHO_PREFIX = "⚙️ "

define echo_configs
	@echo ${ECHO_PREFIX}$1
endef

all: clean build open

build:
	$(call echo_configs,Generating xcodeproj)
	@xcodegen

.PHONY: version
version:
	@ruby Scripts/updateversion.rb ${PROJECT_NAME}

test: clean build
	$(call echo_configs,Starting tests build)
	-make test-for-action
	@open TestResults.xcresult

app: clean build
	$(call echo_configs,Generating .app)
	make app-for-action
	@open "${PROJECT_DIR}/build/${PROJECT_NAME}-iossimulator.xcarchive"

open:
	$(call echo_configs,Opening project)
	@open ${PROJECT_NAME}.xcodeproj

clean:
	$(call echo_configs,Removing auto generated files)
	@-rm -rf ${PROJECT_NAME}.xcodeproj
	@-rm -rf DerivedData
	@-rm -rf build build_data
	@-rm -rf TestResults TestResults.xcresult

test-for-action:
	xcodebuild test \
	-project ${PROJECT_NAME}.xcodeproj \
	-scheme ${PROJECT_NAME} \
	-derivedDataPath ./build_data \
	-destination 'platform=iOS Simulator,name=${TEST_DEVICE}' \
	-destination-timeout=180 \
	-resultBundlePath TestResults

app-for-action:
	xcodebuild archive \
	-project ${PROJECT_NAME}.xcodeproj \
	-scheme ${PROJECT_NAME} \
	-archivePath "${PROJECT_DIR}/build/${PROJECT_NAME}-iossimulator.xcarchive" \
	-sdk iphonesimulator
