bash
#!/bin/bash

# Set variables

KAFKA_TOPIC=${TOPIC_NAME}

REPLICATION_FACTOR=${NEW_REPLICATION_FACTOR}

# Increase replication factor of Kafka topic

kafka-topics.sh --zookeeper ${ZOOKEEPER_URL} --alter --topic $KAFKA_TOPIC --partitions ${PARTITION_COUNT} --replication-factor $REPLICATION_FACTOR