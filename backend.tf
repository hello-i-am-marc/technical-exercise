terraform {
  backend "s3" {
    bucket         = "tech-exercise-tfstate-181137999457"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tech-exercise-tflock"
    encrypt        = true
  }
}