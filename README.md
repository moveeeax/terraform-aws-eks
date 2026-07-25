# terraform-aws-eks

Terraform module that manages an [Amazon
EKS](https://aws.amazon.com/eks/) cluster. It creates a single Kubernetes
control plane wired to the supplied subnets and exposes the API endpoint and
certificate authority data needed to configure kubectl.

Defaults are private: the API server endpoint is reachable from inside the VPC
only, and `api`, `audit` and `authenticator` control plane logs are shipped to
CloudWatch Logs.

## Usage

```hcl
module "eks" {
  source = "github.com/moveeeax/terraform-aws-eks"

  name       = "prod-cluster"
  role_arn   = aws_iam_role.eks.arn
  subnet_ids = ["subnet-0a", "subnet-0b"]

  # Optional: envelope-encrypt Kubernetes secrets with a customer managed key.
  kms_key_arn = aws_kms_key.eks.arn

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

To expose the API server publicly you must opt in *and* say who may reach it —
the module refuses to plan a public endpoint with no CIDR list, because AWS
would silently fall back to `0.0.0.0/0`:

```hcl
module "eks" {
  source = "github.com/moveeeax/terraform-aws-eks"

  name       = "prod-cluster"
  role_arn   = aws_iam_role.eks.arn
  subnet_ids = ["subnet-0a", "subnet-0b"]

  endpoint_public_access = true
  public_access_cidrs    = ["203.0.113.0/24"]
}
```

A runnable example lives in [`examples/basic`](examples/basic).

## Requirements

| Name      | Version  |
|-----------|----------|
| terraform | >= 1.5   |
| aws       | >= 5.0   |

## Inputs

| Name                        | Description                                             | Type           | Default          | Required |
|-----------------------------|---------------------------------------------------------|----------------|------------------|:--------:|
| `name`                      | Name of the EKS cluster.                                | `string`       | n/a              |   yes    |
| `role_arn`                  | ARN of the control plane IAM role.                      | `string`       | n/a              |   yes    |
| `kubernetes_version`        | Desired Kubernetes version.                             | `string`       | `null`           |    no    |
| `subnet_ids`                | Subnet IDs for the control plane (at least two).        | `list(string)` | n/a              |   yes    |
| `endpoint_private_access`   | Reach the API server from within the VPC.               | `bool`         | `true`           |    no    |
| `endpoint_public_access`    | Reach the API server from the public internet.          | `bool`         | `false`          |    no    |
| `public_access_cidrs`       | CIDR blocks allowed to reach the public endpoint. Required when `endpoint_public_access` is true. | `list(string)` | `null` |    no    |
| `security_group_ids`        | Additional control plane security groups.               | `list(string)` | `[]`             |    no    |
| `enabled_cluster_log_types` | Control plane log types to enable.                      | `list(string)` | `["api", "audit", "authenticator"]` | no |
| `kms_key_arn`               | KMS key for envelope encryption of Kubernetes secrets.  | `string`       | `null`           |    no    |
| `tags`                      | Tags applied to the cluster.                            | `map(string)`  | `{}`             |    no    |

## Outputs

| Name                         | Description                                        |
|------------------------------|----------------------------------------------------|
| `id`                         | Name of the EKS cluster.                           |
| `arn`                        | ARN of the EKS cluster.                            |
| `endpoint`                   | Endpoint of the Kubernetes API server.             |
| `certificate_authority_data` | Base64-encoded CA data for the cluster.            |
| `cluster_security_group_id`  | Security group ID created by EKS.                  |

## Tests

The module ships a [`terraform test`](tests) suite that runs against a mocked
AWS provider — no credentials, no network, nothing created:

```sh
terraform init -backend=false
terraform test
```

`mock_provider` needs Terraform (or OpenTofu) >= 1.7. That is a requirement of
the test suite only; the module itself still supports >= 1.5.

## License

[MIT](LICENSE)
