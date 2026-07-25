# Requires Terraform >= 1.7 (or OpenTofu >= 1.7) for `mock_provider`, which lets
# these run with no AWS credentials and no network. The module itself still
# supports >= 1.5 — this requirement is test-only.

mock_provider "aws" {
  # certificate_authority is computed by AWS; give the mock a value so the
  # module outputs can be evaluated.
  mock_resource "aws_eks_cluster" {
    defaults = {
      certificate_authority = [{ data = "bW9jaw==" }]
    }
  }
}

variables {
  name       = "test-cluster"
  role_arn   = "arn:aws:iam::111111111111:role/eks-cluster"
  subnet_ids = ["subnet-aaaaaaaa", "subnet-bbbbbbbb"]
}

run "api_endpoint_is_private_by_default" {
  assert {
    condition     = aws_eks_cluster.this.vpc_config[0].endpoint_public_access == false
    error_message = "The API server endpoint must not be public by default."
  }

  assert {
    condition     = aws_eks_cluster.this.vpc_config[0].endpoint_private_access == true
    error_message = "The API server endpoint must be reachable from the VPC by default."
  }

  assert {
    condition     = var.public_access_cidrs == null
    error_message = "public_access_cidrs must not default to a value; 0.0.0.0/0 must never be implied."
  }
}

run "control_plane_logging_is_on_by_default" {
  assert {
    condition = alltrue([
      for t in ["api", "audit", "authenticator"] :
      contains(aws_eks_cluster.this.enabled_cluster_log_types, t)
    ])
    error_message = "api, audit and authenticator control plane logs must be enabled by default."
  }
}

run "rejects_unknown_log_type" {
  command = plan

  variables {
    enabled_cluster_log_types = ["api", "kubelet"]
  }

  expect_failures = [var.enabled_cluster_log_types]
}

run "rejects_single_subnet" {
  command = plan

  variables {
    subnet_ids = ["subnet-aaaaaaaa"]
  }

  expect_failures = [var.subnet_ids]
}

run "rejects_public_endpoint_without_explicit_cidrs" {
  command = plan

  variables {
    endpoint_public_access = true
  }

  expect_failures = [aws_eks_cluster.this]
}

run "rejects_cluster_with_no_reachable_endpoint" {
  command = plan

  variables {
    endpoint_private_access = false
    endpoint_public_access  = false
  }

  expect_failures = [aws_eks_cluster.this]
}

run "public_endpoint_accepts_explicit_cidrs" {
  variables {
    endpoint_public_access = true
    public_access_cidrs    = ["203.0.113.0/24"]
  }

  assert {
    condition     = aws_eks_cluster.this.vpc_config[0].public_access_cidrs == toset(["203.0.113.0/24"])
    error_message = "public_access_cidrs must be passed through to the cluster."
  }
}

run "secrets_encryption_is_wired_when_a_key_is_supplied" {
  variables {
    kms_key_arn = "arn:aws:kms:us-east-1:111111111111:key/00000000-0000-0000-0000-000000000000"
  }

  assert {
    condition     = length(aws_eks_cluster.this.encryption_config) == 1
    error_message = "A KMS key ARN must enable envelope encryption."
  }

  assert {
    condition     = aws_eks_cluster.this.encryption_config[0].resources == toset(["secrets"])
    error_message = "Envelope encryption must cover Kubernetes secrets."
  }

  assert {
    condition     = aws_eks_cluster.this.encryption_config[0].provider[0].key_arn == var.kms_key_arn
    error_message = "The supplied KMS key must be used for envelope encryption."
  }
}

run "no_encryption_config_without_a_key" {
  assert {
    condition     = length(aws_eks_cluster.this.encryption_config) == 0
    error_message = "No encryption_config block should be emitted when kms_key_arn is null."
  }
}
