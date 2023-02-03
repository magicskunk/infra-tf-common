output "cluster_name" {
  value = aws_eks_cluster.eks_cluster.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "cluster_ca_certificate" {
  value = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}

output "autoscaler" {
  value = {
    role = aws_iam_role.autoscaler.arn
    oidc = aws_iam_openid_connect_provider.cluster.arn
  }
}
