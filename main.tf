module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.36.0"

  cluster_name                             = "${var.aws_region}-${var.environment}-eks"
  cluster_version                          = var.cluster_version
  bootstrap_self_managed_addons            = var.bootstrap_self_managed_addons
  enable_cluster_creator_admin_permissions = var.enable_cluster_creator_admin_permissions

  vpc_id                                 = local.vpc_id
  subnet_ids                             = data.aws_subnet_ids.private.ids
  control_plane_subnet_ids               = data.aws_subnet_ids.public.ids
  cluster_endpoint_public_access         = var.cluster_endpoint_public_access
  cluster_endpoint_public_access_cidrs   = var.cluster_endpoint_public_access_cidrs
  cluster_enabled_log_types              = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  cloudwatch_log_group_retention_in_days = var.cloudwatch_log_group_retention_in_days
  enable_irsa                            = var.enable_irsa

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni = {
      most_recent = true
    }
  }

  eks_managed_node_group_defaults = {
    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large", var.node_instance_type]
    capacity_type  = "ON_DEMAND"
    iam_role_additional_policies = {
      AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
      AmazonEKS_CNI_Policy               = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
      AmazonEKSWorkerNodePolicy          = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
      AmazonSSMManagedInstanceCore       = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      AWSXrayWriteOnlyAccess             = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
      CloudWatchAgentServerPolicy        = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
    }
  }

  eks_managed_node_groups = {
    "${var.environment}-eks-node-blue" = {
      ami_type                  = "AL2_x86_64"
      instance_types            = ["m5.xlarge"]
      capacity_type             = "ON_DEMAND"
      attach_node_role_policies = true
      min_size                  = 2
      desired_size              = 2
      max_size                  = 10
      root_block_device = {
        volume_size = 100
        volume_type = "gp3"
      }
      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 100
            volume_type           = "gp3"
            delete_on_termination = true
            encrypted             = true
          }
        }
      }
    }

    "${var.environment}-eks-node-green" = {
      ami_type       = "AL2_x86_64"
      instance_types = ["m5.xlarge"]
      capacity_type  = "ON_DEMAND"
      min_size       = 2
      desired_size   = 2
      max_size       = 10
      root_block_device = {
        volume_size = 100
        volume_type = "gp3"
      }
    }
    "${var.environment}-eks-node-spot" = {
      ami_type       = "AL2_x86_64"
      instance_types = ["m5.xlarge", "m5a.xlarge", "m5d.xlarge", "m6i.xlarge"]
      capacity_type  = "SPOT"
      min_size       = 1
      desired_size   = 2
      max_size       = 10
      disk_size      = 100
      disk_type      = "gp3"
      disk_encrypted = true

      taints = [{
        key    = "spot-instance"
        value  = "true"
        effect = "NO_SCHEDULE"
      }]

      labels = {
        "node-type" = "spot"
      }
    }
  }

  fargate_profiles = {
    default = {
      name = "default"
      selectors = [
        {
          namespace = "default"
        }
      ]
    }
  }

  cluster_security_group_additional_rules = {
    "allow_node_to_control_plane" = {
      description = "Node groups to cluster API"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      type        = "ingress"
      cidr_blocks = [data.aws_vpc.vpc.cidr_block]
    }
    "node_egress" = {
      description = "Node groups outbound traffic"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "egress"
      cidr_blocks = ["0.0.0.0/0"]
    }
    "allow_all_pod_traffic" = {
      description = "Allow all traffic between pods"
      protocol    = "all"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      cidr_blocks = [data.aws_vpc.vpc.cidr_block]
    }
    "node_to_node" = {
      description = "Node to node communication"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    "nodes_kubelet" = {
      description = "Cluster API to node kubelets"
      protocol    = "tcp"
      from_port   = 10250
      to_port     = 10250
      type        = "ingress"
      cidr_blocks = [data.aws_vpc.vpc.cidr_block]
    }
  }
}
