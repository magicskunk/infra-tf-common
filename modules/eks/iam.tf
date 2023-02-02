data "aws_iam_policy_document" "eks_cluster" {
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_cluster" {
  name               = "${var.cluster_name}_role"
  assume_role_policy = data.aws_iam_policy_document.eks_cluster.json
}
# aws managed policies for eks cluster -> https://docs.aws.amazon.com/eks/latest/userguide/security-iam-awsmanpol.html
# https://docs.aws.amazon.com/eks/latest/userguide/service_IAM_role.html
# AmazonEKSClusterPolicy is an AWS managed policy that provides Amazon EKS with the permissions it needs to create
# and delete AWS resources on your behalf
data "aws_iam_policy" "eks_cluster" {
  name = "AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cluster" {
  policy_arn = data.aws_iam_policy.eks_cluster.arn
  role       = aws_iam_role.eks_cluster.name
}

########################
# Eks Node
########################
# policy for a worker node
# https://docs.aws.amazon.com/eks/latest/userguide/create-node-role.html
data "aws_iam_policy_document" "eks_node" {
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_node" {
  name               = "${var.cluster_name}_node_role"
  assume_role_policy = data.aws_iam_policy_document.eks_node.json
}

# https://docs.aws.amazon.com/eks/latest/userguide/security-iam-awsmanpol.html#security-iam-awsmanpol-AmazonEKSWorkerNodePolicy
data "aws_iam_policy" "node_worker" {
  name = "AmazonEKSWorkerNodePolicy"
}

# TODO Read about CNI
data "aws_iam_policy" "node_cni" {
  name = "AmazonEKS_CNI_Policy"
}

data "aws_iam_policy" "node_ecr" {
  name = "AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "node_worker" {
  policy_arn = data.aws_iam_policy.node_worker.arn
  role       = aws_iam_role.eks_node.name
}

resource "aws_iam_role_policy_attachment" "node_cni" {
  policy_arn = data.aws_iam_policy.node_cni.arn
  role       = aws_iam_role.eks_node.name
}

resource "aws_iam_role_policy_attachment" "node_ecr" {
  policy_arn = data.aws_iam_policy.node_ecr.arn
  role       = aws_iam_role.eks_node.name
}
