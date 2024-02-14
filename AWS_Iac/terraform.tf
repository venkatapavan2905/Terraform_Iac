terraform {
  backend "s3" {
    bucket = "value"
    key = "value"
    region = "var.region"
    encrypt = true
    dynamodb_table = "terraform-lock"    
  }
}