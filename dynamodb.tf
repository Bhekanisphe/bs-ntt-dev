resource "aws_dynamodb_table" "BS-Automated-Testing-Table" {
  name         = "bs-automated-testing-iac"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "flow-name:testing-option"

  dynamic "config" {
    for_each = var.attributes
    attribute {
      name = config.value.name
      type = config.value.type
    }

  # Enable stream — sends change events to Lambda
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES" # OPTIONS: KEYS_ONLY | NEW_IMAGE | OLD_IMAGE | NEW_AND_OLD_IMAGES

  tags = {
    Environment = "development"
    Application = "terraform"
  }
}
}