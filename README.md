# 🎯 Operation GoldenEye

**A James Bond-inspired DevOps engineering project demonstrating Infrastructure as Code, secure AWS authentication, automated infrastructure validation, deployment workflows, drift detection, and controlled teardown.**

[![Terraform](https://img.shields.io/badge/Terraform-IaC-7B42BC?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-Infrastructure-FF9900?logo=amazonaws&logoColor=white)](https://aws.amazon.com/)
[![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-CI%2FCD-2088FF?logo=githubactions&logoColor=white)](https://github.com/features/actions)
[![Security](https://img.shields.io/badge/Auth-OIDC%20%7C%20IAM-2E8B57)](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_oidc.html)

## 🕵️ Mission briefing

Operation GoldenEye is a hands-on DevOps project built around a fictional MI6 mission. Its objective is to demonstrate how cloud infrastructure can be defined, validated, deployed, monitored for configuration drift, and safely removed using a repeatable workflow.

The project combines Terraform with GitHub Actions and AWS IAM OpenID Connect (OIDC), avoiding the need to store long-lived AWS access keys in GitHub repository secrets.

Rather than treating deployment as a single action, GoldenEye explores the infrastructure lifecycle: **validate, plan, deploy, detect drift, investigate changes, and destroy resources when they are no longer needed.**

### Mission objectives

- Define AWS networking and load-balancing infrastructure using Terraform.
- Authenticate GitHub Actions to AWS using OIDC and IAM roles.
- Store Terraform state remotely in Amazon S3.
- Automate Terraform quality checks, validation, planning, and deployment.
- Detect manual changes that cause infrastructure drift.
- Separate read-oriented drift detection from deployment permissions.
- Provide a controlled, auditable teardown workflow.
- Document the implementation and its results with screenshots.

## 🏗️ Architecture

![Operation GoldenEye architecture](docs/images/architecture.png)

*Architecture diagram: GitHub Actions authenticates to AWS through OIDC, assumes an IAM role, and runs Terraform against the remote state and AWS infrastructure.*

### Architecture components

| Component | Purpose |
|---|---|
| GitHub repository | Stores Terraform configuration, workflow definitions, and project documentation. |
| GitHub Actions | Automates quality checks, identity verification, planning, deployment, drift detection, and teardown. |
| AWS IAM OIDC provider | Allows GitHub Actions to obtain temporary AWS credentials through a trusted identity relationship. |
| IAM roles | Provide role-specific permissions for deployment, drift detection, and identity verification. |
| Terraform | Defines and manages the infrastructure declaratively. |
| Amazon S3 | Stores Terraform state remotely, with versioning and public-access protections configured on the state bucket. |
| Amazon VPC | Provides the project's isolated virtual network. |
| Public subnets | Host the public-facing load balancer across two Availability Zones. |
| Internet gateway and route table | Provide the network route required for public internet connectivity. |
| Security group | Controls traffic to the load balancer, including HTTP access on port 80. |
| Application Load Balancer | Exposes the demonstration endpoint through a public DNS name. |

### Network design

The Terraform configuration defines a VPC using `10.70.0.0/16`, with two public subnets selected across the first two available Availability Zones. An internet gateway and public route table provide the routing required by the public-facing load balancer.

The load balancer security group permits inbound HTTP traffic on port 80 and allows outbound traffic. The Application Load Balancer uses a fixed-response listener, returning the demonstration message:

> MI6 GOLDENEYE: Mission control is operational.

This initial implementation focuses on cloud networking, load balancing, identity, and infrastructure lifecycle automation. It does not require an EC2 application fleet or container platform to demonstrate these concepts.

## 🧰 Technology stack

- **Infrastructure as Code:** Terraform
- **CI/CD and automation:** GitHub Actions
- **Cloud platform:** Amazon Web Services
- **Identity and permissions:** AWS IAM and GitHub Actions OIDC
- **Networking:** Amazon VPC, subnets, internet gateway, route tables, and security groups
- **Traffic entry point:** AWS Application Load Balancer
- **Remote state:** Amazon S3
- **Source control:** Git and GitHub
- **Testing approach:** Automated Terraform checks, execution plans, deployment runs, and a controlled drift experiment

## 🔐 Security design

Security is part of the implementation rather than an afterthought.

### OIDC authentication

GitHub Actions uses an OIDC trust relationship to assume an AWS IAM role and obtain temporary credentials. This avoids storing long-lived AWS access keys in GitHub repository secrets.

The trust relationship should be restricted to the intended repository and GitHub environment, with the audience and subject conditions configured to match the actual GitHub-issued token claims.

### Role separation

GoldenEye uses distinct roles for different workflow purposes:

- **OIDC identity verification:** Tests the GitHub-to-AWS identity integration.
- **Terraform deployment:** Performs the infrastructure operations permitted by its IAM policies.
- **Drift detection:** Reads the infrastructure and Terraform state required to calculate a plan, with state-lock permissions where necessary.

Separate role names do not, by themselves, guarantee least privilege. Effective permissions depend on the attached policies, trust policies, permissions boundaries, and any applicable organisation-level controls.

### Remote state protection

The Terraform backend uses Amazon S3 to maintain state outside the GitHub Actions runner. The bucket is configured with versioning and Block Public Access settings, helping protect state history and prevent unintended public exposure.

Terraform state can contain sensitive infrastructure metadata. Access should therefore remain restricted to authorised roles and users. Public-access protection does not replace IAM access controls or encryption.

### Change control

The deployment and teardown workflows are manually initiated. GitHub environment protection rules can add an approval gate where configured.

A Terraform plan should always be reviewed for unexpected changes before a destructive or consequential operation. A workflow that generates and applies a plan in one job does not automatically provide a separate approval point between those two steps.

## ⚙️ Automation workflows

The project uses GitHub Actions to demonstrate different stages of the infrastructure lifecycle.

### 1. Terraform quality checks

The quality-check workflow provides an automated place to run the project's configured checks. This helps identify configuration issues before infrastructure changes are applied.

**Evidence:** `docs/images/terraform-quality-checks.png`

### 2. OIDC identity verification

The identity-check workflow verifies that GitHub Actions can authenticate to AWS using the configured OIDC trust relationship and assume the expected IAM role.

The AWS identity output provides evidence of the identity used by the workflow. It should be checked against the intended AWS account and role.

**Evidence:** `docs/images/oidc-identity-check.png`

### 3. Terraform validation

After the VPC and Application Load Balancer configuration was committed, the validation workflow checked whether the Terraform configuration was syntactically and structurally valid.

Validation is an important quality gate, but it does not prove that AWS will successfully create every resource or that the resulting infrastructure is secure.

**Evidence:** `docs/images/terraform-validation.png`

### 4. Terraform plan

The plan workflow initialises Terraform, validates the configuration, and generates a proposed set of infrastructure changes. The plan can be inspected before deciding whether to deploy.

The plan is a preview, not an infrastructure deployment. In this project's workflow, the generated plan file is runner-local unless explicitly published as an artifact.

**Evidence:** `docs/images/terraform-plan.png`

### 5. Terraform plan and apply

The deployment workflow generates a Terraform plan and applies it to create or update the resources represented in the configuration and state.

The resulting AWS resources can then be checked in the AWS console. Any production approval depends on the GitHub environment protection rules actually configured for the repository.

**Evidence:** `docs/images/terraform-plan-and-apply.png`

### 6. Infrastructure drift detection

Drift detection compares the configuration and Terraform state with the infrastructure currently observed in AWS. It runs a Terraform plan and interprets the result to distinguish between no changes, detected changes, and an execution error.

The scheduled workflow is configured to run daily at 08:17 UTC, in addition to supporting manual execution.

A plan that identifies drift is a signal to investigate. It does not automatically remediate the change or apply infrastructure modifications.

**Evidence:** `docs/images/drift-detection.png`

### 7. Controlled teardown

The teardown workflow generates and displays a destroy plan before applying it. Once the destructive apply step is enabled and executed, Terraform attempts to remove the resources managed by the selected state.

This is a real infrastructure deletion operation, not simply a validation or dry run. The Terraform state backend must remain available during teardown.

After the run, the AWS console and Terraform state should be checked to verify the outcome. A successful workflow is useful evidence, but remaining resources and failed deletions should still be investigated.

**Evidence:** `docs/images/terraform-destroy.png`

## 🧪 Drift experiment

One of the key experiments in Operation GoldenEye was to introduce a manual change to a resource managed by Terraform and observe whether the drift-detection workflow identified it.

### Experiment procedure

1. Establish a clean Terraform plan as the baseline.
2. Change a tag on the existing Application Load Balancer directly in AWS.
3. Run the drift-detection workflow.
4. Inspect the plan and the workflow's reported exit code.
5. Confirm that Terraform identifies the difference between the declared configuration and the observed infrastructure.
6. Restore the intended configuration through Terraform.
7. Run drift detection again to confirm that no further changes are reported.

### Observed change

During the experiment, the ALB's expected `Owner` tag was changed manually to `ManualChangeTest`, with the value `GoldenEye`.

Terraform subsequently identified a change that would restore the expected `Owner = GoldenEye` tag and remove the manually introduced tag.

The plan reported:

`Plan: 0 to add, 1 to change, 0 to destroy`

Terraform's detailed exit-code behaviour is important to this experiment:

| Exit code | Meaning |
|---|---|
| `0` | The plan completed successfully with no changes. |
| `1` | Terraform encountered an error. |
| `2` | The plan completed successfully and changes were detected. |

The workflow was adjusted to handle these outcomes correctly, including disabling the Terraform setup action's output wrapper so the script could reliably capture Terraform's exit code.

This experiment demonstrates why automated drift detection must interpret both the plan and its exit status rather than relying only on a successful workflow step.

### Experiment evidence

Save the actual screenshots from your run using these filenames:

- `docs/images/drift-baseline.png`
- `docs/images/drift-manual-change.png`
- `docs/images/drift-detected-change.png`
- `docs/images/drift-remediated.png`

## 💷 Cost management

GoldenEye is designed as a focused demonstration, not as a claim that every deployment is free.

AWS charges can depend on the region, resource configuration, duration, traffic, and applicable account credits or free-tier eligibility. In particular, a public Application Load Balancer can incur charges while it exists, even when it returns only a fixed response and receives little traffic.

Cost-control practices for this project include:

- Deploy only the infrastructure required for the experiment.
- Check the AWS billing console and any applicable budgets or alerts.
- Review the Terraform plan before creating additional resources.
- Destroy the demonstration infrastructure when it is no longer needed.
- Verify that resources have actually been removed after teardown.
- Retain the Terraform state backend until it is safe to retire it separately.

**Cost status:** Actual project cost should be confirmed using AWS billing data. No zero-cost claim is made here without supporting evidence.

## 🛠️ Failure handling and operational considerations

| Scenario | Expected response |
|---|---|
| Terraform validation fails | Review the configuration error and correct it before deployment. |
| OIDC authentication is rejected | Check the IAM trust policy, repository/environment subject, token audience, and workflow permissions. |
| Terraform plan proposes unexpected changes | Stop before applying, inspect the proposed changes, and investigate state or configuration differences. |
| Drift is detected | Review the plan and determine whether the change was intentional before remediating it. |
| Drift detection returns an error | Investigate authentication, state access, permissions, provider errors, and workflow logs. |
| Terraform apply fails | Inspect the failed resource and AWS error, then determine whether a partial deployment occurred. |
| Terraform destroy fails | Identify resources that remain, resolve dependency or permission problems, and generate a fresh destroy plan before retrying. |
| Resources remain after teardown | Check the relevant AWS services and Terraform state rather than assuming the workflow's final message proves complete removal. |

## 🚀 How to reproduce

This project is designed around the repository and GitHub Actions workflows.

### Prerequisites

- A GitHub repository containing the Terraform configuration and workflow files.
- An AWS account and a selected deployment region.
- An AWS IAM OIDC provider configured for GitHub Actions.
- IAM roles with suitable trust policies and permissions for identity checks, deployment, state access, drift detection, and teardown.
- An S3 Terraform backend with the expected bucket, key, region, and state-lock configuration.
- GitHub environment variables configured with the correct role ARNs.
- Any required GitHub environment protection rules configured and tested.

### Workflow sequence

1. Review the Terraform configuration and repository structure.
2. Run the Terraform quality-check workflow.
3. Run the OIDC identity-check workflow.
4. Commit the networking and load-balancer configuration.
5. Run Terraform validation.
6. Run the Terraform plan workflow and inspect the proposed changes.
7. Run the deployment workflow when ready to create or update the infrastructure.
8. Verify the deployed resources in the AWS console.
9. Run drift detection and perform the controlled manual-tag experiment.
10. Restore the expected configuration and verify a clean plan.
11. Run the controlled teardown workflow when the infrastructure is no longer required.
12. Verify resource removal and review AWS billing afterwards.

The exact resources created or removed depend on the Terraform configuration and the state selected by the workflow. Confirm the AWS account, region, backend, and plan before executing deployment or teardown.

## ⚠️ Scope and limitations

- The load balancer uses an HTTP fixed response to demonstrate networking and traffic entry; it is not a full application deployment.
- HTTPS, custom domains, an application fleet, and production application health checks are outside the scope of this initial implementation.
- A successful Terraform validation does not guarantee a successful AWS deployment.
- A Terraform plan can detect differences but does not automatically decide whether a manual change is legitimate.
- OIDC security depends on the correctness of IAM trust policies and effective permissions.
- A separate IAM role does not guarantee least privilege unless its policies enforce it.
- A destroy workflow only removes resources managed by the selected Terraform state and permitted by AWS; it is not a general AWS-account cleanup mechanism.
- Actual costs and cleanup results must be verified against the AWS account rather than inferred from workflow success alone.

## 📚 Key lessons

Operation GoldenEye explores several practical DevOps principles:

- **Identity before automation:** CI/CD workflows need a tightly controlled identity before they can safely interact with cloud resources.
- **Infrastructure as Code:** Declarative configuration makes intended infrastructure changes reviewable and repeatable.
- **State matters:** Remote Terraform state is central to tracking and managing infrastructure.
- **Plans are decision points:** Reviewing proposed changes can prevent accidental modifications and destructive operations.
- **Drift needs detection and interpretation:** Manual changes can create configuration differences, and automation must report them accurately.
- **Least privilege is operational:** IAM permissions should match the specific needs of each workflow.
- **Teardown is part of the lifecycle:** Deleting temporary infrastructure and verifying cleanup are as important as creating it.
- **Evidence improves trust:** Screenshots of real workflow runs and AWS configuration help demonstrate what was actually tested.

## 📸 Evidence gallery

The screenshots below document the implementation from initial security configuration through deployment, drift detection, and cleanup.

### Quality and identity

![Terraform quality checks](docs/images/terraform-quality-checks.png)

*Terraform quality checks.*

![OIDC identity verification](docs/images/oidc-identity-check.png)

*GitHub Actions identity verification against AWS.*

### State security

![S3 bucket configuration](docs/images/s3-bucket-security.png)

*S3 Terraform state bucket, versioning, and Block Public Access settings.*

### Validation and deployment

![Terraform validation](docs/images/terraform-validation.png)

*Successful Terraform validation after committing the infrastructure configuration.*

![Terraform plan](docs/images/terraform-plan.png)

*Terraform's proposed infrastructure changes.*

![Terraform plan and apply](docs/images/terraform-plan-and-apply.png)

*Terraform deployment workflow.*

### Drift detection

![Infrastructure drift detection](docs/images/drift-detection.png)

*Automated drift-detection result.*

![Manual drift experiment](docs/images/drift-manual-change.png)

*The intentional manual change used in the drift experiment.*

![Detected drift](docs/images/drift-detected-change.png)

*Terraform's plan identifying the configuration difference.*

![Remediated drift](docs/images/drift-remediated.png)

*Evidence of the restored configuration and clean plan.*

### Deployment and teardown

![Running a deployment](docs/images/deployment-run.png)

*Deployment workflow evidence.*

![Terraform destroy](docs/images/terraform-destroy.png)

*Destroy plan and teardown workflow result.*

> **Screenshot note:** Keep the screenshots in `docs/images/` using the filenames shown above, or update the Markdown image paths to match your actual filenames. Only describe a run as successful when the screenshot shows that result.

## 🗂️ Repository structure

```text
operation-goldeneye/
├── .github/
│   └── workflows/
│       ├── terraform-plan.yml
│       ├── terraform-apply.yml
│       ├── drift-detection.yml
│       └── ...
├── docs/
│   └── images/
│       ├── architecture.png
│       ├── terraform-quality-checks.png
│       ├── oidc-identity-check.png
│       ├── s3-bucket-security.png
│       ├── terraform-validation.png
│       ├── terraform-plan.png
│       ├── terraform-plan-and-apply.png
│       ├── drift-detection.png
│       ├── drift-baseline.png
│       ├── drift-manual-change.png
│       ├── drift-detected-change.png
│       ├── drift-remediated.png
│       ├── deployment-run.png
│       └── terraform-destroy.png
├── infra/
│   ├── main.tf
│   ├── outputs.tf
│   ├── variables.tf
│   └── ...
└── README.md
```

*Illustrative structure: retain the filenames and paths that actually exist in the repository, and update this tree to reflect the final committed files.*

## 🎯 Final mission status

Operation GoldenEye demonstrates an infrastructure lifecycle built around Terraform, GitHub Actions, AWS OIDC, remote state, network configuration, drift detection, and controlled teardown.

The aim is not simply to deploy cloud resources, but to make the process **repeatable, observable, security-conscious, and reversible**.

*Mission objective: automate responsibly, detect unexpected changes, and leave no unnecessary infrastructure running.*
