# Managed Kubernetes

A managed Kubernetes service runs the control plane for you (API
server, etcd, scheduler) and you attach worker nodes, either
self-managed or in a managed node pool. All three examples here
provision a minimal cluster: one managed node pool, private by
default.

## Concepts and naming

| Concept                     | AWS                          | GCP                              | Azure                          |
|-------------------------------|--------------------------------|------------------------------------|------------------------------------|
| Service name                   | EKS                             | GKE                                | AKS                                |
| The cluster resource            | `aws_eks_cluster`                | `google_container_cluster`         | `azurerm_kubernetes_cluster`       |
| Worker nodes                     | Managed node group               | Node pool                          | Node pool (default pool is part of the cluster resource itself) |
| Cluster identity                  | IAM role (cluster + node group, separate) | Service account on the node pool | Managed identity (system-assigned) |
| Private control plane              | `endpoint_private_access` / `endpoint_public_access` flags | `private_cluster_config` block | `private_cluster_enabled` flag     |

## Design defaults used in this repo

- **Private control plane where the cloud allows it.** No public
  endpoint to the Kubernetes API, matching the "no public access by
  default" theme from every other category in this handbook.
- **A managed node pool, not self-managed nodes.** The cloud patches
  and replaces node OS images; you don't hand-manage a fleet of VMs
  as Kubernetes nodes.
- **Small default node count and size** (1 node, a small instance
  type), a reference cluster, not a production sizing.
- **Cluster identity scoped narrowly**, same principle as the `iam`
  category: nodes get only the permissions they need to function
  (pull images, write logs), not broad account access.

## What differs enough to matter

- **AWS separates cluster and node identity into two distinct IAM
  roles**, each with its own trust policy and its own attached
  policies. GCP and Azure both bundle node identity more directly
  into the node pool or cluster resource.
- **GCP's node pool is a separate resource from the cluster**, and
  the common pattern is removing the automatically-created default
  node pool and adding your own — that's what this repo's GCP example
  does. AWS's node group and Azure's default node pool are both
  declared as part of provisioning the cluster from the start, no
  "remove and replace" step needed.
- **Azure's default node pool lives inside the
  `azurerm_kubernetes_cluster` resource itself**, as a nested block,
  where AWS and GCP both treat the initial node pool as its own
  top-level resource.

## Files in this category

- `aws/kubernetes/main.tf` — EKS cluster with a private endpoint, a managed node group, separate IAM roles for cluster and nodes
- `gcp/kubernetes/main.tf` — GKE cluster with private nodes, default node pool removed and replaced with a dedicated one
- `azure/kubernetes/main.tf` — AKS cluster with a private control plane, a system-assigned managed identity

Each file expects subnet/network values from the `networking`
category's outputs, and this is the one category where AWS
additionally needs a `kubernetes_version` variable due to how often
EKS's supported versions change.
