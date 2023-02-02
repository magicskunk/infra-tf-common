aws_account = {
  shared  = "nonprod"
  sandbox = "nonprod"
  dev     = "nonprod"
  stage   = "nonprod"
  prod    = "prod"
}

aws_region = {
  shared = "eu-central-1"
  sandbox = "eu-central-1"
  dev     = "eu-central-1"
  stage   = "eu-central-1"
  prod    = "eu-central-1"
}

container_repositories = {
  shared = ["seventh-sample-app-shared"]
  sandbox = ["seventh-sample-app-sandbox"]
  dev     = ["seventh-sample-app-dev"]
  stage   = ["seventh-sample-app-stage"]
  prod    = ["seventh-sample-app-prod"]
}

primary_domain = "karambol.dev"

email_from_domain = {
  shared = "karambol.dev"
  sandbox = "sandbox.karambol.dev"
  dev     = "karambol.dev"
  stage   = "stage.karambol.dev"
  prod    = "prod.karambol.dev"
}

cluster_name = {
  nonprod = "magicskunk_cluster_nonprod"
  prod    = "magicskunk_cluster"
}

deployment_flag = {
  vpc = ["shared"]
  eks = ["shared"]
}
