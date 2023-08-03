
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Kafka Offline Partition Detected
---

This incident type occurs when a partition in a Kafka cluster is offline, meaning that it is not currently being served by an active leader. This can cause disruptions to data processing and delivery, and requires investigation and resolution to ensure that the cluster is functioning properly.

### Parameters
```shell
# Environment Variables

export OFFLINE_PARTITION_TOPIC="PLACEHOLDER"

export TOPIC_NAME="PLACEHOLDER"

export PARTITION_NUMBER="PLACEHOLDER"

export KAFKA_BROKER_SERVICE_NAME="PLACEHOLDER"

export KAFKA_BROKER_LOG_FILE="PLACEHOLDER"

export PARTITION_COUNT="PLACEHOLDER"

export NEW_REPLICATION_FACTOR="PLACEHOLDER"

export ZOOKEEPER_URL="PLACEHOLDER"
```

## Debug

### Step 1: Check if Kafka is running
```shell
systemctl status kafka
```

### Step 2: Check the status of the offline partition
```shell
/kafka-topics.sh --describe --zookeeper ${ZOOKEEPER_URL} --topic ${OFFLINE_PARTITION_TOPIC}
```

### Step 3: Check the replication factor for the topic
```shell
/kafka-topics.sh --zookeeper ${ZOOKEEPER_URL}  --describe --topic ${OFFLINE_PARTITION_TOPIC} | grep ReplicationFactor
```

### Step 4: Check the ISR count for the topic
```shell
/kafka-topics.sh --zookeeper ${ZOOKEEPER_URL}  --describe --topic ${OFFLINE_PARTITION_TOPIC} | grep "Isr:"
```

### Step 5: Check the Kafka logs for any errors or warnings related to the offline partition
```shell
tail -f /opt/kafka/logs/server.log | grep ${OFFLINE_PARTITION_TOPIC}
```

### Kafka broker nodes are overloaded or underprovisioned.
```shell


#!/bin/bash



# Set variables

KAFKA_HOME=/opt/kafka

BROKER_HOSTS=""

TOPIC=${TOPIC_NAME}

PARTITION=${PARTITION_NUMBER}

THRESHOLD=90



# Collect metrics

for broker in $BROKER_HOSTS; do

  echo "Broker: $broker"

  ssh $broker "$KAFKA_HOME/bin/kafka-run-class.sh kafka.tools.JmxTool --jmx-url service:jmx:rmi:///jndi/rmi://localhost:9999/jmxrmi --object-name kafka.server:type=ReplicaManager,name=UnderReplicatedPartitions --attribute Value | grep $TOPIC | grep partition=$PARTITION"

done | awk '{print $4}' > /tmp/under_replicated



# Analyze metrics

while read value; do

  if [ $value -gt $THRESHOLD ]; then

    echo "Partition $PARTITION is under-replicated on at least one broker."

    exit 1

  fi

done < /tmp/under_replicated



echo "All brokers are properly replicating partition $PARTITION."

exit 0


```

## Repair

### Increase the replication factor of the Kafka topic where the offline partition occurred. This will create additional replicas of the partition and reduce the likelihood of data loss.
```shell
bash
#!/bin/bash

# Set variables

KAFKA_TOPIC=${TOPIC_NAME}

REPLICATION_FACTOR=${NEW_REPLICATION_FACTOR}

# Increase replication factor of Kafka topic

kafka-topics.sh --zookeeper ${ZOOKEEPER_URL} --alter --topic $KAFKA_TOPIC --partitions ${PARTITION_COUNT} --replication-factor $REPLICATION_FACTOR


```