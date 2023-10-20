bash

#!/bin/bash

# Rebalance the partitions

kafka-topics --bootstrap-server ${BOOTSTRAP_SERVER}  --alter --topic ${TOPIC_NAME} --partitions ${NUM_PARTITIONS}