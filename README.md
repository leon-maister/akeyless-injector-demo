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
| access_db.yaml | **Example**: Advanced usage parsing JSON secrets for PostgreSQL authentication and connection testing. |
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
1. **Auth Method Verification**: Checks if the specified Kubernetes Auth Method exists.
2. **Role & Association**: Ensures the required Role exists and is correctly linked.
3. **Secret Management**: Checks for the target secret; if it's missing, the script **automatically creates it**.
4. **Namespace Setup**: Validates/creates the `akeyless` namespace.
5. **Helm Repository Preparation**: Adds the official Akeyless Helm repository and updates.
6. **Values File Management**: Generates/validates `values.yaml` consistency.

## 🚀 Module Injector Configuration and Start UP
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

## 🛠️ How the Secret Injection Works
1. **Mutation**: When you apply a YAML with the `akeyless/enabled: "true"` annotation, the Akeyless Webhook intercepts the request.
2. **Sidecar & Init**: The webhook automatically injects an **init-container** and a **sidecar container** into your pod.
3. **Transparent Injection**: The infrastructure handles authentication and secret fetching, providing them as standard environment variables. The application doesn't need Akeyless SDKs — it just reads the environment.

## 🛠️ Usage Examples

### 1. Secret Injection (Basic Scenario)
Ensure that in the `env.yaml` file, the parameter `value:` points to an existing secret.

**Initial Deploy:**
```bash
kubectl apply -f env.yaml
```

**Force Redeploy (Trigger Webhook again):**
```bash
kubectl replace --force -f env.yaml
```

**Verify Logs:**
```bash
kubectl logs -l app=hello-secrets
```

### 2. Inject DB secret (Complicated Scenario)
#### 🏗️ Preparation
Before deploying the secret consumption example, prepare the database environment:

**Add Helm Repository & Install PostgreSQL:**
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm install my-postgres bitnami/postgresql --set auth.postgresPassword=postgrespass --set auth.username=myuser --set auth.password=mypassword --set auth.database=mydb
```

#### 🧪 Demo Flow (Manual Validation)
Follow these steps to demonstrate how the Akeyless Injector handles dynamic credentials:

1. **Clean Up Environment**: Remove any existing demo secrets from Akeyless:
   ```bash
   akeyless delete-item --name /Path/To/Json/Secret
   ```

2. **Enable Database Access**:
   ```bash
   kubectl port-forward svc/my-postgres-postgresql 5432:5432 > /dev/null 2>&1 &
   ```

3. **Verify/Create Demo User**:
   - **Show that the demouser does not exist**:
     ```bash
     PGPASSWORD='mypassword' psql -h localhost -U myuser -d mydb -c "\du"
     ```
   - **Create the demouser**:
     ```bash
     PGPASSWORD='mypassword' psql -h localhost -U myuser -d mydb -c "CREATE ROLE demouser WITH LOGIN SUPERUSER PASSWORD 'qwertyQWERTY1@';"
     ```

4. **Populate Akeyless Secret**:
   ```bash
   akeyless create-secret --name /Path/To/Json/Secret --value '{"user_name":"demouser","password":"qwertyQWERTY1@"}' --json
   ```

5. **Apply & Verify Connection**:
   - Ensure `access_db.yaml` points correctly to `akeyless:/Path/To/Json/Secret`.
   - **Deploy (or force-replace) the application:**
     ```bash
     kubectl replace --force -f access_db.yaml
     ```
   - **Check the logs:**
     ```bash
     kubectl logs -l app=hello-db-secrets
     ```

6. **Cleanup**:
   ```bash
   pkill -f "kubectl port-forward svc/my-postgres-postgresql"
   ```

---
**Maintained by**: [leon-maister](https://github.com/leon-maister)

<small><sub>/home/keyless/k8s/injector</sub></small>
