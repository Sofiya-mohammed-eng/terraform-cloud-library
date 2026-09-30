# Terraform Cloud Library

A reference handbook for the same infrastructure across AWS, GCP, and
Azure: a written guide per service category in `docs/`, plus working
Terraform code for each cloud.

## Rules

- Every module is validated with `terraform init`, `fmt -recursive`,
  and `validate`. Run `terraform plan` only if you have real cloud
  credentials configured for that provider.
- **Never run `terraform apply` from this repo without deliberately
  choosing to.** Several of these resources are billable.
- Replace any placeholder value (bucket names, project IDs,
  subscription IDs) before planning or applying.

## Categories

| Category   | Status      |
|------------|-------------|
| Storage    | Done        |
| Networking | Done        |
| Compute    | Done        |
| IAM        | Done        |
| Databases  | Not started |
| Kubernetes | Not started |
