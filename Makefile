IMAGE ?= cs6747/ghidra-server
TAG ?= $(shell git describe --abbrev=0 --tags)

build:
	docker build . -t ${IMAGE}:${TAG}
