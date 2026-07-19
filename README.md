# terraform-aws-eks

Terraform module that manages an [Amazon
EKS](https://aws.amazon.com/eks/) cluster. It creates a single Kubernetes
control plane wired to the supplied subnets and exposes the API endpoint and
certificate authority data needed to configure kubectl.

## Usage

```hcl
module "eks" {
  source = "github.com/moveeeax/terraform-aws-eks"

  name       = "prod-cluster"
  role_arn   = aws_iam_role.eks.arn
  subnet_ids = ["subnet-0a", "subnet-0b"]

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
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
| `endpoint_private_access`   | Reach the API server from within the VPC.               | `bool`         | `false`          |    no    |
| `endpoint_public_access`    | Reach the API server from the public internet.          | `bool`         | `true`           |    no    |
| `public_access_cidrs`       | CIDR blocks allowed to reach the public endpoint.       | `list(string)` | `["0.0.0.0/0"]`  |    no    |
| `security_group_ids`        | Additional control plane security groups.               | `list(string)` | `[]`             |    no    |
| `enabled_cluster_log_types` | Control plane log types to enable.                      | `list(string)` | `[]`             |    no    |
| `tags`                      | Tags applied to the cluster.                            | `map(string)`  | `{}`             |    no    |

## Outputs

| Name                         | Description                                        |
|------------------------------|----------------------------------------------------|
| `id`                         | Name of the EKS cluster.                           |
| `arn`                        | ARN of the EKS cluster.                            |
| `endpoint`                   | Endpoint of the Kubernetes API server.             |
| `certificate_authority_data` | Base64-encoded CA data for the cluster.            |
| `cluster_security_group_id`  | Security group ID created by EKS.                  |

## License

[MIT](LICENSE)
