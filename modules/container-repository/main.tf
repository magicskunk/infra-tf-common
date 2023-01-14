resource "aws_ecr_repository" "repository" {
  for_each             = toset(var.container_repositories)
  name                 = each.key
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = false
  }

  tags = {
    Name = "ecr"
  }
}
