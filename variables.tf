# ======================================================
# AWS
# ======================================================

variable "aws_region" {
  description = "The AWS region where resources will be created (e.g., us-east-1, us-west-2)."
  type        = string
}

# ======================================================
# Tags
# ======================================================

variable "app_id" {
  description = "A unique identifier for your application, used in provisioning profiles."
  type        = string
}

variable "environment" {
  description = "The name of the environment where resources will be deployed (e.g., dev, staging, prod)."
  type        = string
}

# ======================================================
# Module
# ======================================================

variable "cluster_version" {
  description = "Kubernetes `<major>.<minor>` version to use for the EKS cluster (i.e.: `1.27`)"
  type        = string
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint"
  type        = list(string)
}

variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled"
  type        = bool
  default     = false
}

variable "bootstrap_self_managed_addons" {
  description = "Indicates whether or not to bootstrap self-managed addons after the cluster has been created"
  type        = bool
  default     = false
}

variable "enable_cluster_creator_admin_permissions" {
  description = "Indicates whether or not to add the cluster creator (the identity used by Terraform) as an administrator via access entry"
  type        = bool
  default     = true
}

variable "node_instance_type" {
  description = "The type of EC2 instance to run for each oh the EKS worker nodes"
  type        = string
  default     = "m5.2xlarge"
}

variable "cloudwatch_log_group_retention_in_days" {
  description = "Number of days to retain log events"
  type        = number
  default     = 7
}

variable "enable_irsa" {
  description = "Determines whether to create an OpenID Connect Provider for EKS to enable IRSA"
  type        = bool
  default     = true
}
