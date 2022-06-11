module "dynamodb_table" {
  source       = "terraform-aws-modules/dynamodb-table/aws"
  name         = "ws-connections"
  billing_mode = "PROVISIONED"
  hash_key     = "connectionId"

  attributes = [
    {
      name = "connectionId"
      type = "S"
    }
  ]

  read_capacity       = 1
  write_capacity      = 1
  autoscaling_enabled = true
  autoscaling_read = {
    target_value = 70
    max_capacity = 10
  }

  autoscaling_write = {
    target_value = 70
    max_capacity = 10
  }
}
