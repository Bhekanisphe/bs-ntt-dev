resource "aws_connect_hours_of_operation" "BM-Test-HOO" {
  instance_id = var.instance_id
  name        = "BM-Test-HOO - IaC"
  description = "BM test flow office hours of operation"
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
    "Name" = "BM Test flow Hours of Operation"
  }
}