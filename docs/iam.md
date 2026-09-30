# Identity and access management

IAM controls who, or what, can do what, to which resources. The core
idea is the same everywhere: define a set of permitted actions, then
grant that set to an identity, scoped to as narrow a target as
possible. All three clouds default to "deny everything" and require
explicit grants.

## Concepts and naming

| Concept                     | AWS                              | GCP                                  | Azure                             |
|-------------------------------|------------------------------------|-----------------------------------------|--------------------------------------|
| Model                          | IAM policies (JSON documents)      | IAM roles + bindings                    | RBAC (role-based access control)     |
| A set of permitted actions      | Policy                             | Role (predefined or custom)             | Role definition                      |
| Attaching permissions to an identity | Policy attachment / inline policy | IAM binding (role ↔ member)         | Role assignment (role ↔ principal ↔ scope) |
| Identity for a workload (not a person) | IAM role (assumed by a service) | Service account                     | Managed identity                     |
| Narrowest grant target           | Resource ARN in the policy itself  | The resource the binding is set on      | The `scope` on the role assignment   |

## Design defaults used in this repo

- **Custom, narrowly-scoped permissions over broad predefined ones.**
  Each example grants only the specific actions needed (e.g. read a
  single bucket) rather than a broad built-in role like "Storage
  Admin" or "AmazonS3FullAccess".
- **Resource-level scoping wherever the cloud allows it.** Grant
  access to one specific bucket, not every bucket in the account or
  project. This repo's examples deliberately bind to the storage
  bucket created in the `storage` category, to show a scoped grant
  against a real resource rather than an abstract one.
- **Workload identities, not shared credentials.** The examples grant
  access to a service identity (IAM role, service account, managed
  identity), the same kind of identity attached to a compute instance
  in the `compute` category, not to a static access key.

## What differs enough to matter

- **AWS scopes permissions inside the policy document itself**, using
  the resource's ARN. GCP and Azure instead scope permissions by
  *where* you attach the binding or role assignment, the permission
  set is more reusable, but the scope lives in a different place.
- **GCP's IAM is additive only.** There's no explicit "deny" binding
  in ordinary IAM, you grant roles, you don't grant negative
  permissions. AWS and Azure both support explicit deny rules.
- **Azure requires a two-step process:** define the role (the set of
  allowed actions) separately from the role assignment (who gets it,
  and at what scope). AWS and GCP both let you attach directly to a
  predefined or inline permission set without a separate definition
  step for custom cases like these.

## Files in this category

- `aws/iam/main.tf` — a custom IAM policy scoped to one S3 bucket ARN, attached to an IAM role
- `gcp/iam/main.tf` — a custom IAM role with minimal storage-read permissions, bound to a service account at the bucket level
- `azure/iam/main.tf` — a custom role definition with minimal blob-read actions, assigned to a managed identity scoped to one storage account

Each file references the bucket from the `storage` category via a
variable — wire it to that category's `bucket_name` / `bucket_id`
output.
