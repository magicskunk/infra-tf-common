# TODO Read https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html
# guide https://hands-on.cloud/eks-terraform-cluster-deployment-guide/

data "aws_caller_identity" "current" {}

locals {
  aws_account_id  = data.aws_caller_identity.current.account_id
}

resource "aws_cloudwatch_log_group" "eks_cluster" {
  # The log group name format is /aws/eks/<cluster-name>/cluster
  # Reference: https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = 7
  # ... potentially other configuration ...
}

# Eks cluster
resource "aws_eks_cluster" "eks_cluster" {
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster,
    aws_cloudwatch_log_group.eks_cluster
  ]
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn
  enabled_cluster_log_types = ["api", "audit", "authenticator"]
  version = "1.24"

  vpc_config {
    subnet_ids = var.cluster_subnet_ids
  }
  tags = {
    Name = var.cluster_name
  }
}

# Creating the private EKS Node Group
resource "aws_eks_node_group" "private_node_group" {
  depends_on = [
    aws_iam_role_policy_attachment.node_worker,
    aws_iam_role_policy_attachment.node_ecr,
    aws_iam_role_policy_attachment.node_cni
  ]
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.cluster_name}-private-ng"
  node_role_arn   = aws_iam_role.eks_node.arn
  subnet_ids      = var.cluster_nodes_subnet_ids
  # TODO move to vars
  ami_type       = "AL2_x86_64" # AL2_x86_64, AL2_x86_64_GPU, AL2_ARM_64, CUSTOM
  capacity_type  = "ON_DEMAND"  # ON_DEMAND, SPOT
  instance_types = ["t2.micro"]
  disk_size      = 8

  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 1
  }

#  update_config {
#    max_unavailable = 2
#  }

  tags = {
    Name = var.cluster_name
  }
}

data "template_file" "config" {
  template = file("${path.module}/templates/config.tpl")
  vars = {
    certificate_data  = aws_eks_cluster.eks_cluster.certificate_authority[0].data
    cluster_endpoint  = aws_eks_cluster.eks_cluster.endpoint
    aws_region        = var.aws_region
    cluster_name      = var.cluster_name
    account_id        = local.aws_account_id
  }
}

resource "local_file" "config" {
  content  = data.template_file.config.rendered
  filename = "${path.module}/${var.cluster_name}_config"
}

#
## EKS Cluster
#resource "aws_eks_cluster" "this" {
#  name     = "${var.project}-cluster"
#  role_arn = aws_iam_role.cluster.arn
#  version  = "1.21"
#
#  vpc_config {
#    # security_group_ids      = [aws_security_group.eks_cluster.id, aws_security_group.eks_nodes.id]
#    subnet_ids              = flatten([aws_subnet.public[*].id, aws_subnet.private[*].id])
#    endpoint_private_access = true
#    endpoint_public_access  = true
#    public_access_cidrs     = ["0.0.0.0/0"]
#  }
#
#  tags = merge(
#    var.tags
#  )
#
#  depends_on = [
#    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy
#  ]
#}
#
#
## EKS Cluster IAM Role
#resource "aws_iam_role" "cluster" {
#  name = "${var.project}-Cluster-Role"
#
#  assume_role_policy = <<POLICY
#{
#  "Version": "2012-10-17",
#  "Statement": [
#    {
#      "Effect": "Allow",
#      "Principal": {
#        "Service": "eks.amazonaws.com"
#      },
#      "Action": "sts:AssumeRole"
#    }
#  ]
#}
#POLICY
#}
#
#resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
#  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
#  role       = aws_iam_role.cluster.name
#}
#
#
## EKS Cluster Security Group
#resource "aws_security_group" "eks_cluster" {
#  name        = "${var.project}-cluster-sg"
#  description = "Cluster communication with worker nodes"
#  vpc_id      = aws_vpc.this.id
#
#  tags = {
#    Name = "${var.project}-cluster-sg"
#  }
#}
#
#resource "aws_security_group_rule" "cluster_inbound" {
#  description              = "Allow worker nodes to communicate with the cluster API Server"
#  from_port                = 443
#  protocol                 = "tcp"
#  security_group_id        = aws_security_group.eks_cluster.id
#  source_security_group_id = aws_security_group.eks_nodes.id
#  to_port                  = 443
#  type                     = "ingress"
#}
#
#resource "aws_security_group_rule" "cluster_outbound" {
#  description              = "Allow cluster API Server to communicate with the worker nodes"
#  from_port                = 1024
#  protocol                 = "tcp"
#  security_group_id        = aws_security_group.eks_cluster.id
#  source_security_group_id = aws_security_group.eks_nodes.id
#  to_port                  = 65535
#  type                     = "egress"
#}
