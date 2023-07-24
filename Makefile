.PHONY: build
build:
	swift build

.PHONY: test
test:
	swift test | xcpretty


.PHONY: itest
itest:
	cd example && swift run

.PHONY: allTest
allTest: test itest
