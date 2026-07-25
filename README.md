# Kubernetes Authentication Automation (Akeyless)

This repository contains scripts to automate the trust establishment between a Kubernetes cluster and Akeyless Gateway.

### 🎯 Project Goal
**The primary goal of this project is to automate the creation and configuration of an Akeyless Kubernetes Authentication Method.**

## 📂 Core Components
| File | Function |
| :--- | :--- |
| config.sh | **Configuration**: Centralized shared variables for environment, Akeyless, and logging parameters. |
| k8s_auth_creation.sh | **Setup**: Creates K8s namespace, ServiceAccount, and configures Akeyless Auth Method + Gateway Config. |
| clean_up.sh | **Cleanup**: Removes all K8s and Akeyless resources created by the setup script. |

## 🏗️ Setup Scope (k8s_auth_creation.sh)
The `k8s_auth_creation.sh` script automates the entire integration process using values defined in `config.sh`:

### 1. Environment Validation
- Validates the `AKEYLESS_GATEWAY_URL` environment variable.
- Detects the active Kubernetes context, Host, and Issuer URL.

### 2. Kubernetes Resource Provisioning
- **Namespace**: Creates a dedicated namespace for testing.
- **ServiceAccount**: Provisions a `gateway-token-reviewer` account.
- **RBAC**: Configures `system:auth-delegator` permissions via ClusterRoleBinding.
- **JWT Token**: Generates a long-lived Secret-based token for Akeyless to communicate with K8s.

### 3. Akeyless Configuration
- **Auth Method**: Creates a new Kubernetes Authentication Method and generates an Access ID/Private Key.
- **Role Association**: Links the new Auth Method to a specified Akeyless Role (e.g., K8sAccess).
- **Gateway Config**: Configures the Akeyless Gateway with the cluster's CA Cert, Host, Issuer, and Token Reviewer JWT.

## 🧹 Cleanup Scope (clean_up.sh)
The `clean_up.sh` script performs a full teardown of the following resources using values defined in `config.sh`:

### 1. Akeyless Resources
- **Gateway K8s Auth Config**: Removes the configuration from the Gateway.
- **Auth Method**: Deletes the Kubernetes-type authentication method.

### 2. Kubernetes Resources
- **ServiceAccount & Secret**: Removes the dedicated Token Reviewer account and its JWT token.
- **ClusterRoleBinding**: Deletes the `auth-delegator` permission binding.
- **Namespace**: Deletes the entire template namespace.

### 3. Local Files
- **Manifests**: Deletes temporary ".yaml" files.
- **Logs**: Removes the setup log file.

## ⚙️ Configuration Variables
All template variables are managed centrally inside `config.sh`:

### Kubernetes Settings
- **TEST_NS**: `your-namespace`
- **SA_NAME**: `your-service-account-name`
- **SA_FILE/TOKEN_FILE**: Manifests for SA and Secret creation

### Akeyless Settings
- **AUTH_METHOD_NAME**: `/your-path/your-auth-method`
- **GW_CONFIG_NAME**: `your-gw-config-name`
- **GW_URL**: `https://your-akeyless-gateway-url/api/v1`

## 🚀 Usage
1. Configure your environment variables in `config.sh`:
```bash
nano config.sh
```
2. Export your gateway URL:
```bash
export AKEYLESS_GATEWAY_URL="https://your-akeyless-gateway-url/api/v1"
```
3. Install or upgrade the Injector:
```bash
helm upgrade --install injector akeyless/akeyless-secrets-injection --namespace akeyless -f /home/keyless/vcluster/injector-demo/values.yaml
```
4. Run `./k8s_auth_creation.sh` to setup or `./clean_up.sh` to remove resources.

---
**Maintained by**: [leon-maister](https://github.com/leon-maister)

<sub style="color: gray;">/home/keyless/k8s | CS-EKS</sub>
