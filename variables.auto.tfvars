aws_region = {
  sandbox = "eu-central-1"
  dev     = "eu-central-1"
  stage   = "eu-central-1"
  prod    = "eu-central-1"
}

container_repository_name = {
  # Probably we could use same ecr for non-prod
  sandbox = "magicskunk_sandbox"
  dev     = "magicskunk"
  stage   = "magicskunk"
  prod    = "magicskunk_prod"
}
