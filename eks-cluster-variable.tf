variable "eks_master_role_name" {
  description = "Name of the IAM role for EKS master."
  default     = "eks-master"
}

variable "worker_role_name" {
  description = "Name of the IAM role for EKS worker nodes."
  default     = "eks-worker"
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster."
  default     = "eks-cluster"
}

variable "capacity_type" {
  description = "Capacity type for the worker node group."
  default     = "ON_DEMAND"
}

variable "disk_size" {
  description = "Disk size for worker nodes."
  default     = "20"
}

variable "instance_types" {
  description = "List of instance types for worker nodes."
  type        = list(string)
  default     = ["t2.small"]
}

variable "node_group_name" {
  description = "Name of the EKS node group."
  default     = "private-nodegroup"
}

variable "node_labels" {
  description = "Labels to apply to EKS worker nodes."
  type        = map(string)
  default     = {}
}

variable "desired_capacity" {
  description = "Desired capacity of the worker node group."
  default     = 4
}

variable "min_capacity" {
  description = "Minimum capacity of the worker node group."
  default     = 2
}

variable "max_capacity" {
  description = "Maximum capacity of the worker node group."
  default     = 5
}
