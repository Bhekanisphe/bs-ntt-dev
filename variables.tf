variable "instance_id" {

    type = string
    description = "The ID of the AWS Connect instance"
    default = "6e669f6f-3783-4c0e-ac76-4f531575015d"
}

variable "days_of_week" {
    type = set(string)
    description = "List of days of the week for hoo"
    default = ["MONDAY","TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY"]
}

variable "table_name" {
    type = string
    description = "The name of the DynamoDB table"
    default = "BS-Automated-Testing-Table"
}

variable "hash_key" {
    type = string
    description = "The hash key for the DynamoDB table"
    default = "flow-name:testing-option"
}

variable "test_cases" {
    type = map(object({
    flow-name:testing-option = string
    caller_number= string
    description = string
    flow_id = string
    hho_id = string
    hoo_result = string
    queue_id = string
    type = string
    welcome_text = string
    menu_levels = map(object({
        identifier = string
        message = string
        user_action = string
        next = string
    }))}
    
    description = "List of test cases for the DynamoDB table"
    default = {
        "BM-Test-Flow-IaC:1" = {
            flow-name:testing-option = "BM-Test-Flow-IaC:1",
            welcome_text = "Welcome to the test flow",
            caller_number = "+1234567890",
            description = "Test case for BM-Test-Flow-IaC",
            flow_id = aws_connect_contact_flow.BM-Test-Flow-IaC.id,
            hho_id = aws_connect_hours_of_operation.BM-Test-Hours-of-Operation.id,
            hoo_result = "InHour",
            queue_id = aws_connect_queue.BM-Test-General.id,
            type = "DtmfInput",
            menu_levels = {
                "1" = {
                    identifier = "Option 1",
                    message = "Please press one for technial issues. Press 2 for Sales. Press 3 for general queries. Press # to repeat the menu options",
                    user_action = "1",
                    next = "Option 1.2"
                },
                "2" = {
                    identifier = "Option 1.2",
                    message = "Welcome to the technical help menu options. Please press 1 for WiFi issues, press 2 for laptop issues. Press # to repeat or press * to return to the main menu.",
                    user_action = "2",
                    next = "Check queue"
                }
            }
        },
        "BM-Test-Flow-Voice-IaC:2" = {
            flow-name:testing-option = "BM-Test-Flow-Voice-IaC:2",
            welcome_text = "Welcome to the voice test flow",
            caller_number = "+1234567890",
            description = "Test case for BM-Test-Flow-Voice-IaC",
            flow_id = aws_connect_contact_flow.BM-Test-Flow-Voice-IaC.id,
            hho_id = aws_connect_hours_of_operation.BM-Test-Hours-of-Operation.id,
            hoo_result = "InHour",
            queue_id = aws_connect_queue.BM-Test-General.id,
            type = "Utterance",
            menu_levels = {
                "1" = {
                    identifier = "Utterance 1",
                    message = "Please let us know the purpose of your call. You can do this by saying what you need assistance with in a clear voice.",
                    user_action = "1",
                    next = "Check queue"
                },
                "2" = {
                    identifier = "Utterance 2",
                    message = "Welcome to the technical menu. Please specify if you have wifi issues or laptop issues. Please say this in a clear voice.",
                    user_action = "2",
                    next = "Check queue"
                }
            }
        }
    }
}