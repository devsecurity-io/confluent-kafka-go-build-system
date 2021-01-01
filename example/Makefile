ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

PROJECT_NAME:=example
BUILD_IMAGE:=confluent-kafka-go-build-system:1.15.6-alpine3.12

.PHONY: all
all:
	@cd $(ROOT_DIR)
	docker run -d -t --name build-container $(BUILD_IMAGE)
	docker exec -t build-container mkdir -p /go/src/$(PROJECT_NAME)
	docker cp . build-container:/go/src/$(PROJECT_NAME)
	# Download local version of confluent-kafka-go to modify for static compilation
	docker exec -t -w /tmp build-container git clone https://gopkg.in/confluentinc/confluent-kafka-go.v1
	# Initialize go module
	docker exec -t -w /tmp/confluent-kafka-go.v1 build-container go mod init gopkg.in/confluentinc/confluent-kafka-go.v1
	docker exec -t build-container rm -rf /tmp/confluent-kafka-go.v1/kafka/librdkafka
	docker exec -t build-container rm -f /tmp/confluent-kafka-go.v1/kafka/build_darwin.go
	docker exec -t build-container rm -f /tmp/confluent-kafka-go.v1/kafka/build_dynamic.go
	docker exec -t build-container rm -f /tmp/confluent-kafka-go.v1/kafka/build_glibc_linux.go
	docker exec -t build-container rm -f /tmp/confluent-kafka-go.v1/kafka/build_musl_linux.go
	# Create modified version of build_musl_linux.go for static compilation
	echo "// +build "'!'"dynamic\n// +build musl\n\npackage kafka\n\n// #cgo LDFLAGS: -lrdkafka -lz -lcrypto -lssl -lsasl2 -lzstd -llz4 -lcrypto -static\nimport \"C\"\n\n// LibrdkafkaLinkInfo explains how librdkafka was linked to the Go client\nconst LibrdkafkaLinkInfo = \"static musl_linux $(BUILD_IMAGE)\"" > $(ROOT_DIR)/build_musl_linux.go
	docker cp $(ROOT_DIR)/build_musl_linux.go build-container:/tmp/confluent-kafka-go.v1/kafka/build_musl_linux.go
	rm -f $(ROOT_DIR)/build_musl_linux.go
	# Initialize go module
	docker exec -t -w /go/src/$(PROJECT_NAME) build-container go mod init
	# Replace confluent-kafka-go with local version for build
	docker exec -t -w /go/src/$(PROJECT_NAME) build-container go mod edit -replace gopkg.in/confluentinc/confluent-kafka-go.v1=/tmp/confluent-kafka-go.v1
	# amd64 build
	docker exec -t -w /go/src/$(PROJECT_NAME) build-container /bin/bash -c "GOOS=linux GOARCH=amd64 go build -v -ldflags \"-v -s -w -extldflags '-static'\" -a -tags \"static netgo musl\" -installsuffix netgo -o app-amd64"
	mkdir -p $(ROOT_DIR)/bin
	docker cp build-container:/go/src/$(PROJECT_NAME)/app-amd64 ./bin/$(PROJECT_NAME)-amd64
	docker rm -f build-container

.PHONY: clean
clean:
	@-rm -rf $(ROOT_DIR)/bin
