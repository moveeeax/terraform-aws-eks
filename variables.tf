variable "name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "role_arn" {
  description = "ARN of the IAM role that provides permissions for the Kubernetes control plane."
  type        = string
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
  default     = false
}

variable "endpoint_public_access" {
  description = "Whether the cluster API server endpoint is reachable from the public internet."
  type        = bool
  default     = true
}

variable "public_access_cidrs" {
  description = "CIDR blocks allowed to reach the public API server endpoint."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "security_group_ids" {
  description = "Additional security group IDs to associate with the control plane."
  type        = list(string)
  default     = []
}

variable "enabled_cluster_log_types" {
  description = "Control plane log types to enable and ship to CloudWatch Logs."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags applied to the cluster."
  type        = map(string)
  default     = {}
}
