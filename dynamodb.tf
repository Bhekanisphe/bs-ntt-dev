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


locals {
  test_case_flags = {
    for k, v in var.test_cases :
    k => try(v.retry_settings, null) != null
  }

  retry_settings_default = {
    for k, v in var.test_cases :
    k => try(v.retry_settings.default, null) != null
  }

}

resource "aws_dynamodb_table_item" "Test-Case-Items" {
  for_each   = var.test_cases
  table_name = aws_dynamodb_table.BS-Automated-Testing-Table.name
  hash_key   = var.hash_key

  item = local.test_case_flags[each.key] ? (jsonencode({
    "flow_name-testing_option" = { "S" = each.value.flow_name-testing_option },
    "caller_number"            = { "S" = each.value.caller_number },
    "description"              = { "S" = each.value.description },
    "flow_id"                  = { "S" = each.value.flow_id },
    "hoo_id"                   = { "S" = each.value.hoo_id },
    "hoo_result"               = { "S" = each.value.hoo_result },
    "queue_id"                 = { "S" = each.value.queue_id },
    "type"                     = { "S" = each.value.type },
    "welcome_text"             = { "S" = each.value.welcome_text },
    "menu_levels" = { "M" = { for key, value in each.value.menu_levels : key => {
      "M" = {
        "identifier"  = { "S" = value.identifier },
        "message"     = { "S" = value.message },
        "user_action" = { "S" = value.user_action },
        "next"        = { "S" = value.next }
      }
    } } },
    "retry_settings" = { "M" = (
      local.retry_settings_default[each.key] ? 
      { 
        "default" = { "M" = {
          "attempts"         = { "N" = tostring(each.value.retry_settings.default.attempts) },
          "retry_message"    = { "S" = each.value.retry_settings.default.retry_message },
          "transfer_message" = { "S" = each.value.retry_settings.default.transfer_message },
          "wrong_action"     = { "S" = each.value.retry_settings.default.wrong_action }
      } } 
      } :
      {
      "timeout" =  { "M" = {
        "attempts"         = { "N" = tostring(each.value.retry_settings.timeout.attempts) },
        "retry_message"    = { "S" = each.value.retry_settings.timeout.retry_message },
        "transfer_message" = { "S" = each.value.retry_settings.timeout.transfer_message }
      } 
      }
    } )}
  })) : (jsonencode({
    "flow_name-testing_option" = { "S" = each.value.flow_name-testing_option },
    "caller_number"            = { "S" = each.value.caller_number },
    "description"              = { "S" = each.value.description },
    "flow_id"                  = { "S" = each.value.flow_id },
    "hoo_id"                   = { "S" = each.value.hoo_id },
    "hoo_result"               = { "S" = each.value.hoo_result },
    "queue_id"                 = { "S" = each.value.queue_id },
    "type"                     = { "S" = each.value.type },
    "welcome_text"             = { "S" = each.value.welcome_text },
    "menu_levels" = { "M" = { for key, value in each.value.menu_levels : key => {
      "M" = {
        "identifier"  = { "S" = value.identifier },
        "message"     = { "S" = value.message },
        "user_action" = { "S" = value.user_action },
        "next"        = { "S" = value.next }
      }
    } } }
  }))
}
