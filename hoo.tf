resource "aws_connect_hours_of_operation" "BS-Test-HOO" {
  instance_id = var.instance_id
  name        = "BS-Test-HOO - IaC"
  description = "Bs test flow office hours of operation"
  time_zone   = "EST"

  dynamic "config" {
    for_each = var.days_of_week
    content {
      day = config.value
      start_time {
        hours   = 9
        minutes = 0
      }
      end_time {
        hours   = 17
        minutes = 0
      }
    }
  }

  tags = {
    "Name" = "BS Test flow Hours of Operation"
  }
}