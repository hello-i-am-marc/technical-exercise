# Intentional choices for exercise speed: MUTABLE tags allow iterative pushes; AES256 encryption
# (vs CMK) keeps scope tight. Both documented as Phase 7 hardening options.
#trivy:ignore:AVD-AWS-0031
resource "aws_ecr_repository" "app" {
  #checkov:skip=CKV_AWS_136:Using AES256 encryption for exercise speed; CMK encryption documented as Phase 7 hardening option
  #checkov:skip=CKV_AWS_51:Tag mutability MUTABLE for iteration speed; IMMUTABLE documented as stricter alternative

  name                 = "${var.project}-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name = "${var.project}-app"
  }
}

# Lifecycle policy: keep last 10 images, expire older
resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name
  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = { type = "expire" }
      }
    ]
  })
}