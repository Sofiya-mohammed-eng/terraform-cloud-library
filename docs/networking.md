# Virtual networking

Every cloud gives you an isolated, private network that your
resources live inside, split into subnets, with rules controlling
what traffic is allowed in and out.

## Concepts and naming

| Concept                     | AWS                        | GCP                          | Azure                         |
|------------------------------|-----------------------------|-------------------------------|----------------------------------|
| Isolated network              | VPC                          | VPC network                    | Virtual Network (VNet)           |
| Subdivision                   | Subnet (tied to one AZ)      | Subnet (regional, spans zones) | Subnet                           |
| Traffic filtering              | Security group (stateful, per-instance) | Firewall rule (project or network level) | Network Security Group (NSG, per-subnet or per-NIC) |
| Public IP on outbound traffic  | NAT Gateway                  | Cloud NAT                      | NAT Gateway                      |
| Routing between subnets        | Route table                  | Routes (implicit + custom)     | Route table (UDR)                |

## Design defaults used in this repo

- **Private by default.** Resources go in private subnets unless they
  specifically need to be reachable from the internet.
- **A dedicated subnet per tier** (public-facing vs. internal), so
  network rules can be scoped by subnet instead of by individual
  resource.
- **Explicit inbound rules only.** Nothing is opened beyond what's
  declared; there's no default-allow rule left in place.
- **Tags/labels on every resource**, same reasoning as storage: an
  unlabeled VPC or subnet is a mystery six months later.

## What differs enough to matter

- **AWS subnets are zonal; GCP subnets are regional.** An AWS subnet
  lives in one Availability Zone, so multi-AZ setups need multiple
  subnets. A GCP subnet already spans every zone in its region.
- **GCP firewall rules aren't attached to a subnet or instance
  directly** the way AWS security groups or Azure NSGs are — they're
  defined at the network level and apply based on tags or service
  accounts.
- **Azure route tables are explicit (UDR — user-defined routes).**
  AWS and GCP both give you sensible default routing and you override
  it when needed; Azure expects the route table to be associated with
  a subnet deliberately.

## Files in this category

- `aws/networking/main.tf` — VPC, public and private subnets, an internet gateway
- `gcp/networking/main.tf` — VPC network, a subnet, and a firewall rule allowing internal traffic only
- `azure/networking/main.tf` — Virtual network, a subnet, and a network security group
