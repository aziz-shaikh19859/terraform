terraform {
  backend "s3" {
    bucket = "s3-backend-19859"
    key    = "terraform.tfstate"
    region = "ap-south-1"
  }

  
}