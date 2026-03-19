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

## 🏗️ Module Environment Preparation
The purpose of this module is to handle all necessary preparations and resource validations required to successfully run and deploy the Akeyless Injector.

## ⚙️ Configuration
Before running the setup or building images, you must configure the following parameters:

### Akeyless Script Parameters (`injector_preparation.sh`)
- **`AUTH_METHOD_NAME`**: The full path to your Kubernetes Authentication Method.
- **`ROLE_NAME`**: The Akeyless Role that will be associated with the Auth Method.
- **`SECRET_NAME`**: The path where the test secret will be checked or created.
- **`SECRET_VALUE`**: The initial value to be used if the secret does not exist.

## 🚀 Run Preparation
Once configured, execute the preparation script:
```bash
chmod +x injector_preparation.sh
./injector_preparation.sh
```

### 🖥️ Execution Output
The script performs a systematic validation and setup of the environment:
1. **Auth Method Verification**: Checks if the specified Kubernetes Auth Method exists and confirms its type.
2. **Role & Association**: Ensures the required Role exists and is correctly linked to the Auth Method.
3. **Secret Management**: Checks for the target secret; if it's missing, the script **automatically creates it** with the predefined value.
4. **Namespace Setup**: Validates the existence of the `akeyless` namespace in Kubernetes, creating it if necessary.
5. **Helm Repository Preparation**: Automatically adds the official Akeyless Helm repository and performs an update to ensure the latest chart versions are available.
6. **Values File Management**: Checks for an existing `values.yaml`; if missing, it **generates a fresh one** directly from the Akeyless Helm chart. If it exists, it displays key configuration parameters to ensure consistency.

## 🚀 Module Injector Configuration and Start UP
## ⚙️ Configuration
Before deploying, you must ensure the following parameters are correctly configured in your `values.yaml` file:
- **`AKEYLESS_URL`**: The URL of your Akeyless Vault instance.
- **`AKEYLESS_ACCESS_TYPE`**: The authentication type (e.g., k8s).
- **`AKEYLESS_ACCESS_ID`**: Your unique Access ID for the Kubernetes Auth Method.
- **`AKEYLESS_API_GW_URL`**: The API URL of your Akeyless Gateway.
- **`AKEYLESS_K8S_AUTH_CONF_NAME`**: The specific name of the Kubernetes Authentication configuration created in your Gateway.

## 🛠️ Usage Examples
This project demonstrates two primary ways to consume secrets:

### 1. Environment Variable Injection (`env.yaml`)
- Secrets are injected directly into container environment variables using the `akeyless/enabled: "true"` annotation.

### 2. Dynamic DB Credentials (`access_db.yaml`)
- Injects a JSON secret containing database credentials and uses `jq` for runtime parsing.

## 🚀 Quick Start
1. Ensure you are logged into Akeyless CLI and have kubectl access.
2. Open `injector_preparation.sh` and set your specific variables.
3. Run the preparation script (as shown in Run Preparation section).
4. Install the injector using Helm:
```bash
helm install akeyless-secrets-injection akeyless/akeyless-secrets-injection -f values.yaml -n akeyless
```

---
**Maintained by**: [leon-maister](https://github.com/leon-maister)

<small><sub>/home/keyless/akeyless-injector-script</sub></small>
