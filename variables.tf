variable "name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "role_arn" {
  description = "ARN of the IAM role that provides permissions for the Kubernetes control plane."
  type        = string

  validation {
    condition     = can(regex("^arn:[^:]+:iam::\\d{12}:role/", var.role_arn))
    error_message = "role_arn must be a full IAM role ARN, e.g. arn:aws:iam::111111111111:role/eks-cluster."
  }
}

variable "kubernetes_version" {
  description = "Desired Kubernetes version for the cluster. Null uses the AWS default."
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "List of subnet IDs for the cluster control plane. At least two in different AZs."
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "EKS requires at least two subnets in different availability zones."
  }
}

variable "endpoint_private_access" {
  description = "Whether the cluster API server endpoint is reachable from within the VPC."
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Whether the cluster API server endpoint is reachable from the public internet."
  type        = bool
  default     = false
}

variable "public_access_cidrs" {
  description = <<-EOT
    CIDR blocks allowed to reach the public API server endpoint. Must be set
    explicitly whenever `endpoint_public_access` is true: leaving it null makes
    AWS fall back to 0.0.0.0/0, which exposes the API server to the internet.
  EOT
  type        = list(string)
  default     = null

  validation {
    condition = var.public_access_cidrs == null ? true : alltrue([
      for cidr in var.public_access_cidrs : can(cidrhost(cidr, 0))
    ])
    error_message = "Each entry in public_access_cidrs must be a valid CIDR block, e.g. 203.0.113.0/24."
  }
}

variable "security_group_ids" {
  description = "Additional security group IDs to associate with the control plane."
  type        = list(string)
  default     = []
}

variable "enabled_cluster_log_types" {
  description = "Control plane log types to enable and ship to CloudWatch Logs."
  type        = list(string)
  default     = ["api", "audit", "authenticator"]

  validation {
    condition = alltrue([
      for t in var.enabled_cluster_log_types :
      contains(["api", "audit", "authenticator", "controllerManager", "scheduler"], t)
    ])
    error_message = "Valid log types are api, audit, authenticator, controllerManager and scheduler."
  }
}

variable "kms_key_arn" {
  description = <<-EOT
    ARN of a KMS key used for envelope encryption of Kubernetes secrets. Null
    leaves secrets encrypted only by the EKS-managed etcd volume encryption.
  EOT
  type        = string
  default     = null

  validation {
    condition     = var.kms_key_arn == null ? true : can(regex("^arn:[^:]+:kms:[^:]+:\\d{12}:key/", var.kms_key_arn))
    error_message = "kms_key_arn must be a full KMS key ARN, e.g. arn:aws:kms:us-east-1:111111111111:key/00000000-0000-0000-0000-000000000000."
  }
}

variable "tags" {
  description = "Tags applied to the cluster."
  type        = map(string)
  default     = {}
}
