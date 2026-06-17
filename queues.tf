resource "aws_connect_queue" "Technical_Wifi" {
  instance_id           = var.instance_id
  name                  = "BM-Test-Technical-Wifi-IaC"
  description           = "Technical Wifi Queue"
  hours_of_operation_id = aws_connect_hours_of_operation.BM-Test-HOO.hours_of_operation_id

  tags = {
    "Name" = "Technical Wifi Queue",
  }
}

resource "aws_connect_queue" "Technical_Laptop" {
  instance_id           = var.instance_id
  name                  = "BM-Test-Technical-Laptop-IaC"
  description           = "Technical Laptop Queue"
  hours_of_operation_id = aws_connect_hours_of_operation.BS-Test-HOO.hours_of_operation_id

  tags = {
    "Name" = "Technical Laptop Queue",
  }
}

resource "aws_connect_queue" "BM-Test-General" {
  instance_id           = var.instance_id
  name                  = "BM-Test-General-IaC"
  description           = "General Queries Queue"
  hours_of_operation_id = aws_connect_hours_of_operation.BS-Test-HOO.hours_of_operation_id

  tags = {
    "Name" = "General queries Queue",
  }
}

resource "aws_connect_queue" "BM-Test-Sales" {
  instance_id           = var.instance_id
  name                  = "BM-Test-Sales-IaC"
  description           = "Sales Queries Queue"
  hours_of_operation_id = aws_connect_hours_of_operation.BS-Test-HOO.hours_of_operation_id

  tags = {
    "Name" = "Sales queries Queue",
  }
}

resource "aws_connect_queue" "BM-Test-Technical" {
  instance_id           = var.instance_id
  name                  = "BM-Test-Technical-IaC"
  description           = "Technical Queries Queue"
  hours_of_operation_id = aws_connect_hours_of_operation.BS-Test-HOO.hours_of_operation_id

  tags = {
    "Name" = "Technical queries Queue",
  }
}