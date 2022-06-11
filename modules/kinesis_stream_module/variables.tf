variable "kinesis_streams_list" {
  type = map(object({
    shards_count = number
  }))
}

variable "kinesis_retention_period" {
  description = "Kinesis stream retention period"
  type        = number
  default     = 24
}
