terraform {
 backend "s3" {
   bucket = "bs-terraform-state-687244881512-af-south-1-an" # Name of the S3 bucket
   key = "src/terraform.tfstate" # Path to the state file
   region = "af-south-1" # AWS region
   use_lockfile = true # Enable state locking
 }
}