# Virtual machines

A virtual machine is a general-purpose compute instance you manage
yourself: choose an image, a size, attach it to a network, and it
boots like a regular server. All three clouds also offer higher-level
compute (managed containers, serverless), covered in later categories;
this one is the baseline building block.

## Concepts and naming

| Concept                | AWS                          | GCP                              | Azure                          |
|--------------------------|-------------------------------|------------------------------------|-----------------------------------|
| Service name              | EC2                            | Compute Engine                      | Virtual Machines                  |
| The instance itself        | Instance                       | Instance                            | Virtual machine                   |
| OS image                   | AMI (Amazon Machine Image)     | Image (family, e.g. `debian-12`)    | Image (publisher/offer/SKU)       |
| Size/shape                 | Instance type (e.g. `t3.micro`)| Machine type (e.g. `e2-micro`)      | VM size (e.g. `Standard_B1s`)     |
| Attached identity           | IAM instance profile           | Service account                     | Managed identity                  |
| Startup automation           | User data                      | Startup script (metadata)           | Custom script extension           |

## Design defaults used in this repo

- **No public IP by default.** An instance is reachable from inside
  its network only, unless there's a specific reason for it to face
  the internet. Pair with a load balancer or bastion host for
  anything that does need to be reached from outside.
- **Least-privilege identity attached to the instance itself**
  (instance profile / service account / managed identity), so the
  instance can talk to other cloud services without embedding
  long-lived credentials on disk.
- **Locked-down inbound access.** SSH (or other admin access) is
  restricted to a specific source range, never left open to
  `0.0.0.0/0`.
- **Small, burstable sizes as defaults** (`t3.micro`, `e2-micro`,
  `Standard_B1s`), since this library is a learning and reference
  set, not a sizing guide, swap the size variable for real workloads.

## What differs enough to matter

- **AWS attaches identity via a separate "instance profile"** that
  wraps an IAM role; GCP and Azure attach the identity (service
  account / managed identity) to the instance more directly.
- **GCP has no public IP unless you explicitly add an access
  config.** AWS and Azure both default to *assigning* a public IP
  unless you turn it off, so the "no public IP" default here is an
  explicit setting on AWS and Azure, but GCP's natural default
  already matches it.
- **Image selection works differently.** AWS AMIs are region-specific
  and usually looked up via a data source; GCP images are referenced
  by family (always resolves to the latest in that family); Azure
  images are a four-part reference (publisher, offer, SKU, version).

## Files in this category

- `aws/compute/main.tf` — EC2 instance, no public IP, a security group restricted to one CIDR, an IAM instance profile
- `gcp/compute/main.tf` — Compute Engine instance, no external IP, a firewall-tagged network interface, a dedicated service account
- `azure/compute/main.tf` — Linux VM, no public IP, an NSG restricted to one CIDR, a system-assigned managed identity

This category depends on a network to launch into. Each file exposes
a `subnet_id` (or equivalent) variable — wire it to the matching
output from the `networking` category, e.g. `aws/networking`'s
`public_subnet_id` or `private_subnet_id` output.
