# Akeyless Secrets Injection Automation

This repository contains scripts and Kubernetes manifests to automate the deployment of the Akeyless Secrets Injection Webhook and demonstrate secret consumption.

### 🎯 Project Goal
**The primary goal of this project is to automate the preparation of Akeyless resources and the installation of the Mutation Webhook for transparent secret injection into Kubernetes pods.**

## 📂 Core Components
| File | Function |
| :--- | :--- |
| injector_preparation.sh | **Setup**: Validates Akeyless Auth/Roles, creates test secrets, and prepares Helm values. |
| values.yaml | **Configuration**: Helm chart values for the Akeyless Secrets Injection Webhook. |
| env.yaml | **Example**: Deployment using Akeyless secrets as environment variables. |
| access_db.yaml | **Example**: Advanced usage parsing JSON secrets for PostgreSQL authentication. |
| .gitignore | **Maintenance**: Prevents tracking of logs (`pf.log`) and backup files. |

## 🏗️ Setup Scope (injector_preparation.sh)
The `injector_preparation.sh` script ensures all prerequisites are met before installation:

### 1. Akeyless Validation
- Checks if the Kubernetes Auth Method (`/K8s/k8s-auth-leon-test`) exists and is correctly typed.
- Verifies the existence of the `/FullAccess` role and its association with the auth method.

### 2. Secret Provisioning
- Automatically creates a test secret `/K8s/Citi_of_M/my_k8s_secret` if it is missing.

### 3. Kubernetes & Helm Readiness
- Creates and labels the `akeyless` namespace.
- Adds the Akeyless Helm repository and updates charts.
- Generates a default `values.yaml` if one doesn't already exist.

## 🛠️ Usage Examples
This project demonstrates two primary ways to consume secrets:

### 1. Environment Variable Injection (`env.yaml`)
- Secrets are injected directly into container environment variables using the `akeyless/enabled: "true"` annotation.

### 2. Dynamic DB Credentials (`access_db.yaml`)
- Injects a JSON secret containing database credentials.
- Uses a sidecar approach with `jq` to parse credentials and connect to a PostgreSQL instance.

## ⚙️ Configuration Variables
Key settings defined in `values.yaml`:
- **Access ID**: `p-5dlug8q55fc1km`
- **Gateway URL**: `https://gw-gke.lm.cs.akeyless.fans/api/v1`
- **Auth Config Name**: `k8s-config-created-by-script`

## 🚀 Quick Start
1. Ensure you are logged into Akeyless CLI and have kubectl access.
2. Run the preparation script:
```bash
chmod +x injector_preparation.sh
./injector_preparation.sh
```
3. Install the injector using Helm:
```bash
helm install akeyless-secrets-injection akeyless/akeyless-secrets-injection -f values.yaml -n akeyless
```
4. Deploy an example:
```bash
kubectl apply -f env.yaml
```

---
**Maintained by**: [leon-maister](https://github.com/leon-maister)

<small><sub>/home/keyless/akeyless-injector-script</sub></small>
