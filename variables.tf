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

variable "attributes" {
  type = list(object({
    name = string
    type = string # Supported types for index keys are S (String), N (Number), or B (Binary)
  }))
  default = [
    { name = "flow-name:testing-option", type = "S" },
    { name = "caller_number", type = "S" },
    { name = "description", type = "S" },
    { name = "flow_id", type = "S" },
    { name = "hho_id", type = "S" },
    { name = "hoo_result", type = "S" },
    { name = "queue_id", type = "S" },
    { name = "type", type = "S" },
    { name = "welcome_text", type = "S" },
    { name = "menu_levels", type = "M" }
  ]
}