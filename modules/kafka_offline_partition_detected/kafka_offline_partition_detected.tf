resource "shoreline_notebook" "kafka_offline_partition_detected" {
  name       = "kafka_offline_partition_detected"
  data       = file("${path.module}/data/kafka_offline_partition_detected.json")
  depends_on = [shoreline_action.invoke_rebalance_partitions]
}

resource "shoreline_file" "rebalance_partitions" {
  name             = "rebalance_partitions"
  input_file       = "${path.module}/data/rebalance_partitions.sh"
  md5              = filemd5("${path.module}/data/rebalance_partitions.sh")
  description      = "Rebalance the partitions: If the partition is offline due to an imbalance in the Kafka cluster, rebalancing the partitions can help bring the partition back online."
  destination_path = "/tmp/rebalance_partitions.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_rebalance_partitions" {
  name        = "invoke_rebalance_partitions"
  description = "Rebalance the partitions: If the partition is offline due to an imbalance in the Kafka cluster, rebalancing the partitions can help bring the partition back online."
  command     = "`chmod +x /tmp/rebalance_partitions.sh && /tmp/rebalance_partitions.sh`"
  params      = ["BOOTSTRAP_SERVER","TOPIC_NAME","NUM_PARTITIONS"]
  file_deps   = ["rebalance_partitions"]
  enabled     = true
  depends_on  = [shoreline_file.rebalance_partitions]
}

