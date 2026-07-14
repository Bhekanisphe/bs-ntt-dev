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
    default = "bs-automated-testing-iac"
}

variable "hash_key" {
    type = string
    description = "The hash key for the DynamoDB table"
    default = "flow_name-testing_option"
}

variable "region" {
    type = string
    description = "The AWS region name"
    default = "af-south-1"
}

variable "account_id" {
    type = string
    description = "The AWS account ID"
    default = "687244881512"
}

variable "test_cases" {
    type = map(object({
    flow_name-testing_option = string
    caller_number= string
    description = string
    flow_id = string
    hoo_id = string
    hoo_result = string
    queue_id = string
    type = string
    welcome_text = string
    menu_levels = map(object({
        identifier = string
        message = string
        user_action = string
        next = string
    }))
    retry_settings = optional(object({
        default = optional(object({
            attempts = number
            retry_message = string
            transfer_message = string
            wrong_action = string
        }))
        timeout = optional(object({
            attempts = number
            retry_message = string
            transfer_message = string
        }))
    }))
    }))
    
    description = "List of test cases for the DynamoDB table"
    default = {
        "BM-Test-Flow-IaC:1" = {
            flow_name-testing_option = "BM-Test-Flow-IaC:Opt1.2",
            welcome_text = "Welcome to the test flow",
            caller_number = "+1234567892",
            description = "Test case for BM-Test-Flow-IaC",
            flow_id = "f6525c49-27f0-40cd-a84c-89a3848d4463",
            hoo_id = "4605e369-8882-44d8-a3e9-069bb7fb7120",
            hoo_result = "InHour",
            queue_id = "14b354a2-c688-4e1f-9ba6-e90089a615cc",
            type = "DtmfInput",
            menu_levels = {
                "1" = {
                    identifier = "Option 1",
                    message = "Please press one for technical issues. Press two for Sales. Press three for general queries. Press hash to repeat the menu options",
                    user_action = "1",
                    next = "Option 1.2"
                },
                "2" = {
                    identifier = "Option 1.2",
                    message = "Welcome to the technical help menu options. Please press one for WiFi issues, press two for laptop issues. Press hash to repeat or press star to return to the main menu.",
                    user_action = "2",
                    next = "Check queue"
                }
            }
        },
        "BM-Test-Flow-Voice-IaC:2" = {
            flow_name-testing_option = "BM-Test-Flow-Voice-IaC:Technical-Wifi",
            welcome_text = "Welcome to the voice test flow",
            caller_number = "+1234567892",
            description = "Test case for BM-Test-Flow-Voice-IaC",
            flow_id = "a37b12da-3217-4e34-ac9a-20bee93059de",
            hoo_id = "4605e369-8882-44d8-a3e9-069bb7fb7120",
            hoo_result = "InHour",
            queue_id = "73e9d156-a62d-4471-9cbb-af126df78a1d",
            type = "Utterance",
            menu_levels = {
                "1" = {
                    identifier = "Utterance 1",
                    message = "Please let us know the purpose of your call. You can do this by saying what you need assistance with in a clear voice",
                    user_action = "I have a technical problem",
                    next = "Utterance 2"
                },
                "2" = {
                    identifier = "Utterance 2",
                    message = "Welcome to the technical menu. Please specify if you have wifi issues or laptop issues. Please say this in a clear voice.",
                    user_action = "I have wifi issues",
                    next = "Check queue"
                }
            }
        },
        "BM-Test-Flow-IaC:3" = {
            flow_name-testing_option = "BM-Test-Flow-IaC:Opt1-Default",
            welcome_text = "Welcome to the test flow",
            caller_number = "+1234567892",
            description = "Test case for BM-Test-Flow-IaC - default with retry settings",
            flow_id = "f6525c49-27f0-40cd-a84c-89a3848d4463",
            hoo_id = "4605e369-8882-44d8-a3e9-069bb7fb7120",
            hoo_result = "InHour",
            queue_id = "a3ddb3e2-2b7d-4561-9336-749cfa14f910",
            type = "DtmfInput",
            menu_levels = {
                "1" = {
                    identifier = "Option 1",
                    message = "Please press one for technical issues. Press two for Sales. Press three for general queries. Press hash to repeat the menu options",
                    user_action = "1",
                    next = "Option 1.2"
                },
                "2" = {
                    identifier = "Option 1.2",
                    message = "Welcome to the technical help menu options. Please press one for WiFi issues, press two for laptop issues. Press hash to repeat or press star to return to the main menu.",
                    user_action = "default",
                    next = "Check queue"
                }
            },
            retry_settings = {
                default = {
                    attempts         = 3,
                    retry_message    = "You have not selected any option. Please try again.",
                    transfer_message = "You have not selected a correct option, please wait while we transfer you to an agent. Thank you",
                    wrong_action     = "0"
                }
            }
        }
        "BM-Test-Flow-IaC:4" = {
            flow_name-testing_option = "BM-Test-Flow-IaC:Opt1-Timeout",
            welcome_text = "Welcome to the test flow",
            caller_number = "+1234567892",
            description = "Test case for BM-Test-Flow-IaC - timeout with retry settings",
            flow_id = "f6525c49-27f0-40cd-a84c-89a3848d4463",
            hoo_id = "4605e369-8882-44d8-a3e9-069bb7fb7120",
            hoo_result = "InHour",
            queue_id = "a3ddb3e2-2b7d-4561-9336-749cfa14f910",
            type = "DtmfInput",
            menu_levels = {
                "1" = {
                    identifier = "Option 1",
                    message = "Please press one for technical issues. Press two for Sales. Press three for general queries. Press hash to repeat the menu options",
                    user_action = "1",
                    next = "Option 1.2"
                },
                "2" = {
                    identifier = "Option 1.2",
                    message = "Welcome to the technical help menu options. Please press one for WiFi issues, press two for laptop issues. Press hash to repeat or press star to return to the main menu.",
                    user_action = "timeout",
                    next = "Check queue"
                }
            },
            retry_settings = {
                timeout = {
                    attempts         = 2,
                    retry_message    = "You have not selected any option. Please try again.",
                    transfer_message = "You have not selected a correct option, please wait while we transfer you to an agent. Thank you"
                }
            }
        }
        "BM-Test-Flow-IaC:5" = {
            flow_name-testing_option = "BM-Test-Flow-IaC:Main-default",
            welcome_text = "Welcome to the test flow",
            caller_number = "+1234567892",
            description = "Test case for BM-Test-Flow-IaC - main-default",
            flow_id = "f6525c49-27f0-40cd-a84c-89a3848d4463",
            hoo_id = "4605e369-8882-44d8-a3e9-069bb7fb7120",
            hoo_result = "InHour",
            queue_id = "a3ddb3e2-2b7d-4561-9336-749cfa14f910",
            type = "DtmfInput",
            menu_levels = {
                "1" = {
                    identifier = "Option 1",
                    message = "Please press one for technical issues. Press two for Sales. Press three for general queries. Press hash to repeat the menu options",
                    user_action = "default",
                    next = "Check queue"
                }
            },
            retry_settings = {
                default = {
                    attempts         = 3,
                    retry_message    = "You have not selected any option. Please try again.",
                    transfer_message = "You have not selected a correct option, please wait while we transfer you to an agent. Thank you",
                    wrong_action     = "0"
                }
            }
        }
        "BM-Test-Flow-IaC:6" = {
            flow_name-testing_option = "BM-Test-Flow-IaC:Main-timeout",
            welcome_text = "Welcome to the test flow",
            caller_number = "+1234567892",
            description = "Test case for BM-Test-Flow-IaC - main-timeout",
            flow_id = "f6525c49-27f0-40cd-a84c-89a3848d4463",
            hoo_id = "4605e369-8882-44d8-a3e9-069bb7fb7120",
            hoo_result = "InHour",
            queue_id = "a3ddb3e2-2b7d-4561-9336-749cfa14f910",
            type = "DtmfInput",
            menu_levels = {
                "1" = {
                    identifier = "Option 1",
                    message = "Please press one for technical issues. Press two for Sales. Press three for general queries. Press hash to repeat the menu options",
                    user_action = "timeout",
                    next = "Check queue"
                }
            },
            retry_settings = {
                timeout = {
                    attempts         = 2,
                    retry_message    = "You have not selected any option. Please try again.",
                    transfer_message = "You have not selected a correct option, please wait while we transfer you to an agent. Thank you"
                }
            }
        }
        "BM-Test-Voice-IaC:7" = {
            flow_name-testing_option = "BM-Test-Voice-IaC:Main-default",
            welcome_text = "Welcome to the voice test flow",
            caller_number = "+1234567892",
            description = "Test case for BM-Test-Voice-IaC - main-default",
            flow_id = "a37b12da-3217-4e34-ac9a-20bee93059de",
            hoo_id = "4605e369-8882-44d8-a3e9-069bb7fb7120",
            hoo_result = "InHour",
            queue_id = "a3ddb3e2-2b7d-4561-9336-749cfa14f910",
            type = "Utterance",
            menu_levels = {
                "1" = {
                    identifier = "Utterance 1",
                    message = "Please let us know the purpose of your call. You can do this by saying what you need assistance with in a clear voice",
                    user_action = "default",
                    next = "Check queue"
                }
            },
            retry_settings = {
                default = {
                    attempts         = 3,
                    retry_message    = "I didn't quite get that, please try again.",
                    transfer_message = "I didn't quite get that, please hold while I transfer you to an agent.",
                    wrong_action     = "0"
                }
            }
        }
    }
}