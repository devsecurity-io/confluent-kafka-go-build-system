ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

.PHONY: all
all:
	@cd $(ROOT_DIR)
	@docker build -t confluent-kafka-go-build-system:1.15.6-alpine3.12 .

.PHONY: clean
clean:
	@docker rmi confluent-kafka-go-build-system:1.15.6-alpine3.12
