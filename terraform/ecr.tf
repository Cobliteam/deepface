resource "aws_ecr_repository" "deepface_repository" {
  name = "cobli-internal/deepface"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = local.tags

}