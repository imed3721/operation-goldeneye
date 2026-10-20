# Operation GoldenEye
A James Bond-inspired DevOps engineering project demonstrating
GitHub Actions, Terraform, AWS OIDC, IAM, VPC networking,
Application Load Balancer configuration, and infrastructure
drift detection.
## Mission
Build a repeatable and auditable AWS infrastructure deployment
with controlled identity, security boundaries, automated
validation, drift detection, and a safe teardown process.
## Architecture
![GoldenEye architecture](docs/images/architecture.png)
Describe the GitHub Actions pipeline, OIDC trust relationship,
IAM roles, Terraform state, VPC, subnets, security groups,
and Application Load Balancer
## Technology
- GitHub and GitHub Actions
- Terraform
- AWS IAM and OIDC
- Amazon VPC
- Application Load Balancer
- Amazon S3 remote state
- Infrastructure drift detection
## Security decisions
- No long-lived AWS access keys in GitHub Secrets.
- OIDC trust restricted to the intended repository and environment.
- Separate inspection and deployment permissions.
- Infrastructure changes reviewed before deployment.
- Remote state protected with restricted access and versioning.
- No sensitive information stored in the repository.
## Cost controls
Document the AWS account plan, region, applicable credits,
resources created, budget alerts, teardown process, and
remaining-resource verification.
Do not claim that the project is free unless the actual
resource usage and billing evidence support that claim.
## Testing evidence
### Terraform validation
Add the successful GitHub Actions screenshot.
### OIDC identity
Add the successful identity verification screenshot.
### Infrastructure plan
Add a redacted Terraform plan screenshot.
### Drift detection
Show the clean baseline, the detected manual change,
and the clean plan after remediation.
### Teardown
Show the reviewed destroy plan and the resource cleanup evidence.
## Failure handling
Document what happens when validation fails, OIDC is rejected,
a Terraform plan proposes unexpected changes, or the application
health check fails.
## Limitations
Explain which parts were tested without live AWS infrastructure
and which parts were deployed to a real AWS account.
## How to reproduce
List the prerequisites, GitHub workflow sequence, required
configuration, security restrictions, and approved deployment
and cleanup procedures.
## Lessons learned
Explain what you learned about identity, permissions, state,
networking, infrastructure drift, cost, and incident response.
