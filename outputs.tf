output "eks_cluster_id" {
  description = "EKS Cluster ID"
  value       = module.eks.cluster_id
}

output "eks_cluster_arn" {
  description = "EKS Cluster ARN"
  value       = module.eks.cluster_arn
}

output "eks_cluster_endpoint" {
  description = "EKS Cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_version" {
  description = "EKS Cluster version"
  value       = module.eks.cluster_version
}

output "eks_cluster_security_group_id" {
  description = "EKS Cluster security group ID"
  value       = module.eks.cluster_security_group_id
}

output "vpc_id" {
  value = local.vpc_id
}

output "private_subnets" {
  value = data.aws_subnets.private.ids
}

output "public_subnets" {
  value = data.aws_subnets.public.ids
}
