resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
  ]
}

resource "aws_iam_role" "github_role" {
  name        = "github_role"
  description = "Allow github actions to interact with AWS via OIDC"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Sid       = "RoleForGitHubActions",
        Effect    = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        },
        Action    = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_to_ecr_auth_token" {
  role       = aws_iam_role.github_role.name
  policy_arn = aws_iam_policy.ecr_get_authorization_token_policy.arn
}

resource "aws_iam_role_policy_attachment" "github_to_ecr_pull_push" {
  role       = aws_iam_role.github_role.name
  policy_arn = aws_iam_policy.ecr_pull_push_allowed_policy.arn
}


