resource "aws_eks_cluster" "this" {
  name     = var.name
  role_arn = var.role_arn
  version  = var.kubernetes_version

  enabled_cluster_log_types = var.enabled_cluster_log_types

  vpc_config {
    subnet_ids              = var.subnet_ids
    security_group_ids      = var.security_group_ids
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.public_access_cidrs
  }

  dynamic "encryption_config" {
    for_each = var.kms_key_arn == null ? [] : [var.kms_key_arn]

    content {
      resources = ["secrets"]

      provider {
        key_arn = encryption_config.value
      }
    }
  }

  tags = var.tags

  lifecycle {
    precondition {
      condition     = var.endpoint_private_access || var.endpoint_public_access
      error_message = "At least one of endpoint_private_access or endpoint_public_access must be true; EKS rejects a cluster with no reachable API server endpoint."
    }

    precondition {
      condition     = !var.endpoint_public_access || try(length(var.public_access_cidrs), 0) > 0
      error_message = "Set public_access_cidrs to the ranges allowed to reach the API server whenever endpoint_public_access is true; leaving it unset makes AWS default to 0.0.0.0/0."
    }
  }
}
