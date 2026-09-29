# Object storage

Object storage holds files (images, backups, exports, static assets)
as flat objects rather than in a filesystem or database. All three
clouds offer roughly the same thing under different names.

## Concepts and naming

| Concept                  | AWS                          | GCP                          | Azure                          |
|---------------------------|-------------------------------|-------------------------------|----------------------------------|
| Service name              | S3                            | Cloud Storage                 | Blob Storage                     |
| Container for objects     | Bucket                        | Bucket                        | Storage account → Container      |
| Global uniqueness required| Bucket name (globally unique) | Bucket name (globally unique) | Storage account name (globally unique); container name is unique only within the account |
| Object versioning         | Bucket versioning              | Object versioning              | Blob versioning                  |
| Encryption at rest        | On by default (SSE-S3)         | On by default                  | On by default                    |
| Access tiers               | Standard / IA / Glacier        | Standard / Nearline / Coldline / Archive | Hot / Cool / Archive       |

## Security defaults used in this repo

- **Block all public access** at the bucket/account level. Access is
  granted deliberately per use case (signed URLs, specific IAM
  bindings), never by making the bucket itself public.
- **Uniform access control** where the cloud offers it (GCP's uniform
  bucket-level access, disabling per-object ACLs) so permissions live
  in one place, not scattered across individual objects.
- **Tags/labels** on every resource, since untagged cloud resources
  are the single most common cause of "what is this and can I delete
  it" during a cost review.

## What differs enough to matter

- **Azure has an extra layer.** AWS and GCP buckets are addressed
  directly; Azure needs a storage account *and* a container inside it,
  and IAM, replication, and access tier settings mostly live on the
  account, not the container.
- **Global uniqueness applies to different things.** On AWS and GCP,
  the bucket name itself must be globally unique. On Azure, it's the
  storage account name; container names only need to be unique inside
  that account.
- **Azure storage account names are more restricted:** lowercase
  letters and numbers only, no hyphens, 3–24 characters.

## Files in this category

- `aws/storage/main.tf` — S3 bucket with public access blocked
- `gcp/storage/main.tf` — Cloud Storage bucket with uniform access and public access prevention
- `azure/storage/main.tf` — Storage account and a private container
