resource "aws_dynamodb_table" "BS-Automated-Testing-Table" {
  name         = "bs-automated-testing-iac"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "flow_name-testing_option"
    // Only primary key is required for a DynamoDB table, but you can add additional attributes if needed
    attribute {
        name = "flow_name-testing_option"
        type = "S"
    }
  # Enable stream — sends change events to Lambda
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES" # OPTIONS: KEYS_ONLY | NEW_IMAGE | OLD_IMAGE | NEW_AND_OLD_IMAGES

  tags = {
    Environment = "development"
    Application = "terraform"
  }
}

resource "aws_dynamodb_table_item" "Test-Case-Items" {
    for_each = var.test_cases
    table_name = var.table_name
    hash_key   = var.hash_key

    item = jsonencode({
        "flow_name-testing_option" = each.value["flow_name-testing_option"]
        "caller_number"            = each.value.caller_number
        "description"              = each.value.description
        "flow_id"                  = each.value.flow_id
        "hho_id"                   = each.value.hho_id
        "hoo_result"               = each.value.hoo_result
        "queue_id"                 = each.value.queue_id
        "type"                     = each.value.type
        "welcome_text"             = each.value.welcome_text
        "menu_levels"              = each.value.menu_levels
    })

}
