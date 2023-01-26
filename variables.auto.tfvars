env_code = "sandbox"

aws_region = {
  sandbox = "eu-central-1"
  dev     = "eu-central-1"
  stage   = "eu-central-1"
  prod    = "eu-central-1"
}

container_repositories = {
  sandbox = ["seventh-sample-app-sandbox"]
  dev     = ["seventh-sample-app-dev"]
  stage   = ["seventh-sample-app-stage"]
  prod    = ["seventh-sample-app-prod"]
}

email_from_domain = "karambol.dev"
