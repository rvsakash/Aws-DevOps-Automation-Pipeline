# Multi-Node AWS Infrastructure Automation & Application Deployment Pipeline

An automated CI/CD GitOps pipeline that provisions highly available AWS EC2 infrastructure using Terraform and deploys a containerised web application across distributed target nodes via Ansible, all managed through a centralized Jenkins Master server.

## 🚀 System Architecture Overview

*   **Jenkins Master Node:** Configured on a primary AWS EC2 instance, serving as the central automation controller hosting Jenkins, Terraform, and Ansible.
*   **Infrastructure as Code (IaC):** Terraform dynamically provisions target infrastructure securely based on structural templates.
*   **Configuration Management:** Ansible orchestrates environment initialization, installs dynamic system modules, and manages multi-node application runtimes.
*   **Application Runtime:** Dynamic target nodes operate containerised dependencies to host decoupled web environments.

---

## 📂 Project Structure

```text
.
├── ansible/                  # System orchestration workspace
│   ├── roles/                # Modular framework configurations
│   │   └── docker_install/   # Reusable role to install & configure Docker
│   ├── ansible.cfg           # Core Ansible execution and SSH behavior configuration
│   ├── aws_ec2.yml           # Dynamic Inventory plugin configuration for AWS
│   ├── deploy-playbook.yml   # Core operational orchestration workflow
│   └── vault.yml             # Encrypted storage for environment secrets (Ansible Vault)
├── app/                      # Decoupled application source code
│   ├── Dockerfile            # Container construction specification
│   └── index.html            # Static application payload
├── terraform/                # Infrastructure definitions blueprint
│   ├── main.tf               # Primary asset allocations
│   ├── variables.tf          # Configurable environmental declarations
│   └── output.tf             # Dynamic platform structural telemetry
└── Jenkinsfile               # Declarative workflow lifecycle definition
```

---

## 🛠️ Execution Lifecycle Workflow

1.  **Code Commit & Version Tracking:** Features and structural alterations are pushed from the local workspace (`VS Code`) to the target GitHub `dev` branch.
2.  **Smarter Pipeline Automation (Poll SCM):** The Jenkins Master node systematically reviews the remote repository structure every minute, abstracting networking dependencies like Webhooks to avoid Dynamic IP disruptions.
3.  **Dynamic Infrastructure Provisioning:** Jenkins triggers the `Terraform Apply` stage to safely initialize structural cloud profiles and maps active execution runtimes.
4.  **Target Node Orchestration:** The pipeline utilizes temporary SSH keys securely through isolated credential storage to invoke Ansible configurations against runtime dependencies using decoupled configurations (`ansible.cfg`).
5.  **Decoupled Multi-Node Deployment:** Ansible decrypts deployment tokens via `vault.yml` and triggers the `docker_install` role to securely manage container components directly across target systems to serve modular live web payloads instantly.

---

## ⚙️ Core Technical Specifications

### Terraform Platform Architecture
*   Automates structural resource maps across highly available cloud platforms securely.
*   Decoupled dynamic values separate logical frameworks directly from global system structures.
*   Dynamically registers operational properties back into local storage configurations for seamless handoffs.

### Ansible Execution Automation
*   Leverages **Ansible Roles (`docker_install`)** for modular, maintainable, and reusable tasks across systems.
*   Utilizes **Ansible Vault (`vault.yml`)** to safely inject and decrypt sensitive tokens without exposing plaintext keys in git history.
*   Establishes dynamic runtime modules without manually tracking dynamic SSH identities via optimized target parameters.

### Jenkins Pipeline & Server Resilience
*   Implements declarative lifecycle structures to safely isolate critical secrets from build logs.
*   Configured with local storage optimizations and active execution overrides to protect the build agent from host platform disk exhaustion under high loads.

---

## 🔬 Interviewer Discussion Points / Key Learnings

*   **Dynamic Environments Handling:** Optimized the automation loop via Poll SCM tracking to prevent connectivity breaking when underlying server host IPs reset dynamically.
*   **Handoff Automation:** Structured automated telemetry pipes so infrastructure configurations seamlessly hand active execution context directly down to subsequent workflow operators.
*   **Optimized Resource Allocation:** Configured internal process overrides directly inside system management lifecycles to consistently run complex deployments on small compute sizes safely.
