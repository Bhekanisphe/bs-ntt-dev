resource "aws_dynamodb_table" "BS-Automated-Testing-Table" {
  name         = "bs-automated-testing-iac"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "flow-name:testing-option"

    attribute {
        name = "flow-name:testing-option"
        type = "S"
    }
    attribute {
        name = "caller_number"
        type = "S"
    }
    attribute {
        name = "description"
        type = "S"
    }
    attribute {
        name = "flow_id"
        type = "S"
    }
    attribute {
        name = "hho_id"
        type = "S"
    }
    attribute {
        name = "hoo_result"
        type = "S"
    }
    attribute {
        name = "queue_id"
        type = "S"
    }
    attribute {
        name = "type"
        type = "S"
    }
    attribute {
        name = "welcome_text"
        type = "S"
    }
    attribute {
        name = "menu_levels"
        type = "M"
    }
  # Enable stream — sends change events to Lambda
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES" # OPTIONS: KEYS_ONLY | NEW_IMAGE | OLD_IMAGE | NEW_AND_OLD_IMAGES

  tags = {
    Environment = "development"
    Application = "terraform"
  }
}
