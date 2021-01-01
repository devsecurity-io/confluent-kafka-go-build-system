package main

import (
	kafka "gopkg.in/confluentinc/confluent-kafka-go.v1/kafka"
)

func main() {
	// do nothing example just to get librdkafka to link

	consumer, err := kafka.NewConsumer(&kafka.ConfigMap{
		"bootstrap.servers": "",
		"group.id":          "",
		"auto.offset.reset": "earliest"})

	if err != nil {
		panic(err)
	}

	consumer.Close()
}
