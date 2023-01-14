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

# Looks like I'll need this per env
resource "aws_iam_policy" "ecr_get_authorization_token_policy" {
  name        = "ecr_get_authorization_token"
  description = "Allow fetching of authorization token for ECR repo"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "EcrGetAuthorizationToken",
        "Effect" : "Allow",
        "Action" : [
          "ecr:GetAuthorizationToken"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_policy" "ecr_pull_push_allowed_policy" {
  name        = "aws_ecr_repository_pull_push_allowed_policy"
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
