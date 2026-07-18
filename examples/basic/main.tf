terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

variable "region" {
  description = "AWS region for the provider."
  type        = string
  default     = "us-east-1"
}

variable "cluster_role_arn" {
  description = "ARN of the EKS cluster IAM role."
  type        = string
}

variable "subnet_ids" {
  description = "At least two subnet IDs in different AZs."
  type        = list(string)
}

provider "aws" {
  region = var.region
}

module "eks" {
  source = "../.."

  name       = "example-cluster"
  role_arn   = var.cluster_role_arn
  subnet_ids = var.subnet_ids

  tags = {
    Environment = "sandbox"
    ManagedBy   = "terraform"
  }
}

output "cluster_endpoint" {
  value = module.eks.endpoint
}
