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
# The Amazon VPC CNI plugin for Kubernetes is the networking plugin for pod networking in Amazon EKS clusters.
# The CNI plugin is responsible for allocating VPC IP addresses to Kubernetes nodes and configuring the necessary networking for pods on each node.
# The plugin requires IAM permissions, provided by the AWS managed policy AmazonEKS_CNI_Policy, to make calls to AWS APIs on your behalf
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

################
# Autoscaler
################
# https://www.kubecost.com/kubernetes-autoscaling/kubernetes-cluster-autoscaler/
# https://docs.aws.amazon.com/eks/latest/userguide/autoscaling.html#cluster-autoscaler
data "tls_certificate" "cluster" {
  url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}
resource "aws_iam_openid_connect_provider" "cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

data "aws_iam_policy_document" "autoscaler_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.cluster.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:shared-autoscaler-aws-cluster-autoscaler"]
    }

    principals {
      # e.g. arn:aws:iam::000000000000:oidc-provider/oidc.eks.eu-central-1.amazonaws.com/id/EXAMPLEF955859E129CBFBD561FC806D
      identifiers = [aws_iam_openid_connect_provider.cluster.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "autoscaler" {
  name               = "${var.organization_name}_${var.env_code}_AmazonEKSClusterAutoscalerRole"
  assume_role_policy = data.aws_iam_policy_document.autoscaler_role_policy.json
}

# https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/aws/README.md#full-cluster-autoscaler-features-policy-recommended
# maybe one of managed policies could be used here https://docs.aws.amazon.com/eks/latest/userguide/security-iam-awsmanpol.html
data "aws_iam_policy_document" "autoscaler_policy" {
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeLaunchTemplateVersions",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "ec2:DescribeInstanceTypes",
      "eks:DescribeNodegroup",
    ]
    #    condition {
    #      test     = "StringEquals"
    #      variable = "aws:ResourceTag/k8s.io/cluster-autoscaler/${var.cluster_name}"
    #      values   = ["owned"]
    #    }
  }
}

resource "aws_iam_policy" "autoscaler" {
  name        = "${var.organization_name}_${var.env_code}_AmazonEKSClusterAutoscalerPolicy"
  description = "EKS autoscaling policy"

  policy = data.aws_iam_policy_document.autoscaler_policy.json
}

resource "aws_iam_role_policy_attachment" "autoscaler" {
  role       = aws_iam_role.autoscaler.name
  policy_arn = aws_iam_policy.autoscaler.arn
}
