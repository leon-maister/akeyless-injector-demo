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
| .gitignore | **Maintenance**: Prevents tracking of local logs (`pf.log`) and backup files. |

## 🛠️ Prerequisites
Before starting this demo, you must have a functional **Akeyless Kubernetes Auth Method** configured in your Gateway. If you haven't set this up yet, you can use this automation tool:
- **K8s Auth Setup Tool**: [Kubernetes-Authentication](https://github.com/leon-maister/Kubernetes-Authentication)

## 🏗️ Setup Scope (injector_preparation.sh)
The `injector_preparation.sh` script ensures all prerequisites are met before installation. **Before running, you must configure the following variables inside the script:**

### 1. Akeyless Configuration Parameters
- **`AUTH_METHOD_NAME`**: The full path to your Kubernetes Authentication Method.
- **`ROLE_NAME`**: The Akeyless Role that will be associated with the Auth Method.
- **`SECRET_NAME`**: The path where the test secret will be checked or created.
- **`SECRET_VALUE`**: The initial value to be used if the secret does not exist.

### 2. Automation Logic
- **Validation**: Verifies that the Auth Method exists, is of type `k8s`, and is correctly linked to the specified Role.
- **Secret Provisioning**: Checks for the secret and creates it if it is missing.
- **Infrastructure**: Prepares the `akeyless` namespace and initializes Helm configurations.

## 🛠️ Usage Examples
This project demonstrates two primary ways to consume secrets:

### 1. Environment Variable Injection (`env.yaml`)
- Secrets are injected directly into container environment variables using the `akeyless/enabled: "true"` annotation.

### 2. Dynamic DB Credentials (`access_db.yaml`)
- Injects a JSON secret containing database credentials and uses `jq` for runtime parsing.

## ⚙️ Configuration Variables
Key settings defined in `values.yaml`:
- **Access ID**: Your Akeyless Access ID.
- **Gateway URL**: Your Akeyless Gateway API URL.
- **Auth Config Name**: The name of the K8s Auth configuration.

## 🚀 Quick Start
1. Ensure you are logged into Akeyless CLI and have kubectl access.
2. Open `injector_preparation.sh` and set your specific variables.
3. Run the preparation script:
```bash
chmod +x injector_preparation.sh
./injector_preparation.sh
```
4. Install the injector using Helm:
```bash
helm install akeyless-secrets-injection akeyless/akeyless-secrets-injection -f values.yaml -n akeyless
```

---
**Maintained by**: [leon-maister](https://github.com/leon-maister)

<small><sub>/home/keyless/akeyless-injector-script</sub></small>
