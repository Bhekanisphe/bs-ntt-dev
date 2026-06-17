resource "aws_connect_contact_flow" "BS-Test-Flow" {
  instance_id  = var.instance_id
  name         = "BS-Test-IaC-Flow"
  description  = "Test Contact Flow made by IaC with file upload"
  type         = "CONTACT_FLOW"
  filename     = "contact_flow.json"
  content_hash = filebase64sha256("contact_flow.json")
  tags = {
    "Name"        = "BS-Test-IaC-Flow",
    "Application" = "Terraform",
    "Method"      = "Create"
  }
}