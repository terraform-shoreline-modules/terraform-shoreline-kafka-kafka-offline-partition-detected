resource "shoreline_notebook" "kafka_offline_partition_detected" {
  name       = "kafka_offline_partition_detected"
  data       = file("${path.module}/data/kafka_offline_partition_detected.json")
  depends_on = [shoreline_action.invoke_kafka_partition_check,shoreline_action.invoke_increase_kafka_topic_replication]
}

resource "shoreline_file" "kafka_partition_check" {
  name             = "kafka_partition_check"
  input_file       = "${path.module}/data/kafka_partition_check.sh"
  md5              = filemd5("${path.module}/data/kafka_partition_check.sh")
  description      = "Kafka broker nodes are overloaded or underprovisioned."
  destination_path = "/agent/scripts/kafka_partition_check.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "increase_kafka_topic_replication" {
  name             = "increase_kafka_topic_replication"
  input_file       = "${path.module}/data/increase_kafka_topic_replication.sh"
  md5              = filemd5("${path.module}/data/increase_kafka_topic_replication.sh")
  description      = "Increase the replication factor of the Kafka topic where the offline partition occurred. This will create additional replicas of the partition and reduce the likelihood of data loss."
  destination_path = "/agent/scripts/increase_kafka_topic_replication.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_kafka_partition_check" {
  name        = "invoke_kafka_partition_check"
  description = "Kafka broker nodes are overloaded or underprovisioned."
  command     = "`chmod +x /agent/scripts/kafka_partition_check.sh && /agent/scripts/kafka_partition_check.sh`"
  params      = ["TOPIC_NAME","PARTITION_NUMBER"]
  file_deps   = ["kafka_partition_check"]
  enabled     = true
  depends_on  = [shoreline_file.kafka_partition_check]
}

resource "shoreline_action" "invoke_increase_kafka_topic_replication" {
  name        = "invoke_increase_kafka_topic_replication"
  description = "Increase the replication factor of the Kafka topic where the offline partition occurred. This will create additional replicas of the partition and reduce the likelihood of data loss."
  command     = "`chmod +x /agent/scripts/increase_kafka_topic_replication.sh && /agent/scripts/increase_kafka_topic_replication.sh`"
  params      = ["NEW_REPLICATION_FACTOR","PARTITION_COUNT","ZOOKEEPER_URL","TOPIC_NAME"]
  file_deps   = ["increase_kafka_topic_replication"]
  enabled     = true
  depends_on  = [shoreline_file.increase_kafka_topic_replication]
}

