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

### 🚀 Deployment
Once the configuration is verified, install the injector using the following command:
```bash
helm install injector akeyless/akeyless-secrets-injection --namespace akeyless -f values.yaml
```

### 🔍 Verify Installation
After deployment, ensure the Injector is up and running:
```bash
kubectl get all -n akeyless
```

## 🛠️ Usage Examples
This project demonstrates two primary ways to consume secrets:

### 1. Secret Injection (basic scenario)
- Ensure that in the `env.yaml` file, the parameter `value:` points to a secret variable that actually exists in your Akeyless Vault.
- Once verified, deploy the example using:
```bash
kubectl apply -f env.yaml
```
- Check the logs to verify secret injection:
```bash
kubectl logs -l app=hello-secrets
```

### 2. Inject DB secret (complicated scenario)
#### 🏗️ Preparation
Before deploying the secret consumption example, prepare the database environment:

**Add Helm Repository:**
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```

**Install PostgreSQL:**
```bash
helm install my-postgres bitnami/postgresql --set auth.postgresPassword=postgrespass --set auth.username=myuser --set auth.password=mypassword --set auth.database=mydb
```

> **Note:** This command creates two users: 
> 1. **postgres** (Superuser) with password `postgrespass`.
> 2. **myuser** (App User) with password `mypassword` and owner rights to the `mydb` database.

#### 🧪 Demo Flow (Manual Validation)
Follow these steps to demonstrate how the Akeyless Injector handles dynamic credentials:

1. **Clean Up Environment**: Remove any existing demo secrets from Akeyless:
   ```bash
   akeyless delete-item --name /Path/To/Json/Secret
   ```

2. **Enable Database Access**: Establish port forwarding to allow the CLI to interact with the database:
   ```bash
   kubectl port-forward svc/my-postgres-postgresql 5432:5432 > /dev/null 2>&1 &
   ```

3. **Verify/Create Demo User**: 
   - Connect as `myuser` and ensure the `demouser` does not exist (`\du`).
   - Create the `demouser` with Login and Superuser rights for the demo purposes.

4. **Populate Akeyless Secret**: Create a JSON secret in Akeyless containing the newly created credentials:
   ```bash
   akeyless create-secret --name /Path/To/Json/Secret --value '{"user_name":"demouser","password":"qwertyQWERTY1@"}' --json
   ```

5. **Apply & Verify**: Deploy the application and check how it parses the JSON secret:
   ```bash
   kubectl apply -f access_db.yaml
   ```

6. **Cleanup**: Kill the port-forward process when finished:
   ```bash
   pkill -f "kubectl port-forward svc/my-postgres-postgresql"
   ```

---
**Maintained by**: [leon-maister](https://github.com/leon-maister)

<small><sub>/home/keyless/akeyless-injector-script</sub></small>
