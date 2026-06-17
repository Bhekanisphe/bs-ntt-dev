resource "aws_connect_contact_flow" "BM-Test-Flow" {
  instance_id  = var.instance_id
  name         = "BM-Test-IaC-Flow"
  description  = "Test Contact Flow made by IaC with file upload"
  type         = "CONTACT_FLOW"
  filename     = "contact_flow.json"
  content_hash = filebase64sha256("contact_flow.json")
  tags = {
    "Name"        = "BM-Test-IaC-Flow",
    "Application" = "Terraform",
    "Method"      = "Create"
  }
}