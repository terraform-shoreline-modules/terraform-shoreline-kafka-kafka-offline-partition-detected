

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