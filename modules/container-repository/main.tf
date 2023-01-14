resource "aws_ecr_repository" "main" {
  name                 = var.container_repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }

  tags = {
    Name = "ecr"
  }
}

# do I need this env based?
resource "aws_iam_policy" "aws_ecr_repository_main_pull_allowed_policy" {
  name        = "ecr-pull-allowed-policy"
  description = "Allow pull from ECR policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllowPull",
        "Effect" : "Allow",
        "Action" : [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ],
        "Resource" : aws_ecr_repository.main.arn
      }
    ]
  })
}

resource "aws_iam_policy" "aws_ecr_repository_main_pull_push_allowed_policy" {
  name        = "ecr-pull-push-allowed-policy"
  description = "Allow pull & push to ecr policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllowPullPush",
        "Effect" : "Allow",
        "Action" : [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ],
        "Resource" : aws_ecr_repository.main.arn
      }
    ]
  })
}
