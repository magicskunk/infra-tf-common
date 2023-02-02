resource "aws_ecr_repository" "repository" {
  for_each             = toset(lookup(var.container_repositories, var.env_code))
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

locals {
  repositories = [for repository in aws_ecr_repository.repository : repository.arn]
}

resource "aws_iam_policy" "github_ecr_pull_push_access" {
  name        = "${var.env_code}_github_ecr_pull_push_access"
  description = "Allow pull & push to ecr policy"

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
      },
      {
        "Sid" : "AllowEcrPull",
        "Effect" : "Allow",
        "Action" : [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ],
        "Resource" : local.repositories
      },
      {
        "Sid" : "AllowEcrPullPush",
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
        "Resource" : local.repositories
      }
    ]
  })
}

data "aws_iam_role" "github_actions_oidc" {
  name = var.github_oidc_role_name
}

resource "aws_iam_role_policy_attachment" "github_ecr_pull_push_access" {
  role       = data.aws_iam_role.github_actions_oidc.name
  policy_arn = aws_iam_policy.github_ecr_pull_push_access.arn
}
