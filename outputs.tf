output "id" {
  description = "Name of the EKS cluster."
  value       = aws_eks_cluster.this.id
}

output "arn" {
  description = "ARN of the EKS cluster."
  value       = aws_eks_cluster.this.arn
}

output "endpoint" {
  description = "Endpoint of the Kubernetes API server."
  value       = aws_eks_cluster.this.endpoint
}

output "certificate_authority_data" {
  description = "Base64-encoded certificate authority data for the cluster."
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "cluster_security_group_id" {
  description = "Security group ID created by EKS for the control plane."
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}
