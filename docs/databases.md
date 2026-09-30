# Managed relational databases

A managed database service runs a database engine (Postgres, MySQL,
SQL Server) for you: patching, backups, and failover are handled by
the cloud rather than by hand on a VM. All three examples here use
Postgres, since it's the same engine as Taskboard's own database.

## Concepts and naming

| Concept                     | AWS                          | GCP                              | Azure                              |
|-------------------------------|--------------------------------|------------------------------------|---------------------------------------|
| Service name                   | RDS                             | Cloud SQL                          | Azure Database for PostgreSQL         |
| The running database instance   | DB instance                     | Cloud SQL instance                 | Flexible Server                       |
| Sizing                           | Instance class (e.g. `db.t3.micro`) | Tier (e.g. `db-f1-micro`)      | SKU (e.g. `B_Standard_B1ms`)          |
| Network placement                 | DB subnet group + security group | Private services access / authorized networks | Delegated subnet or firewall rules |
| High availability option           | Multi-AZ deployment             | Regional (HA) availability type    | Zone-redundant HA                     |
| Automated backups                  | On by default, configurable retention | On by default, configurable retention | On by default, configurable retention |

## Design defaults used in this repo

- **No public access.** The database is reachable only from inside
  its own network, never with a public endpoint open to the internet.
  This mirrors Taskboard's own Postgres container, which has no
  `ports:` mapping to the host.
- **Credentials never hardcoded.** The admin password is a variable
  with no default, marked `sensitive`, meant to come from an
  environment variable or a secrets manager, not typed into a `.tf`
  file. (Full secrets-manager integration is out of scope for this
  category; the `sensitive` marking is the baseline habit.)
- **Encryption at rest on by default**, matching what all three
  clouds already do automatically for managed database services.
- **Small default sizing**, same reasoning as compute: this is a
  reference set, not a capacity plan.

## What differs enough to matter

- **Network isolation is set up differently.** AWS uses a DB subnet
  group plus a security group, both defined as separate resources
  pointing at the database. GCP mostly uses "private services access"
  (a VPC peering-based mechanism) for private connectivity. Azure
  Flexible Server can use a delegated subnet directly, integrating
  more tightly into the VNet than the other two.
- **GCP Cloud SQL bundles the database and the "server" concept
  together** in one resource; AWS and Azure both have a similar
  single-resource model for the basic case, but AWS separates the
  parameter group (engine configuration) out more often in real
  setups.
- **Azure Flexible Server's HA option is a property on the server
  resource itself** (zone-redundant HA); AWS's Multi-AZ and GCP's
  regional availability are both configured as flags on their
  respective instance resource too, so this one is actually fairly
  consistent across all three.

## Files in this category

- `aws/databases/main.tf` — RDS Postgres instance, private only, in a DB subnet group scoped to the private subnet from the networking category
- `gcp/databases/main.tf` — Cloud SQL Postgres instance, private IP only
- `azure/databases/main.tf` — Azure Database for PostgreSQL Flexible Server, no public network access

Each file expects a `subnet_id` / `private_network` value from the
`networking` category's outputs.
