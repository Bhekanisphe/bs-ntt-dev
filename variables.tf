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
