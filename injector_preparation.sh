#!/bin/bash

set -e

# --- Variables ---
SECRET_NAME="/K8s/Citi_of_M/my_k8s_secret"
SECRET_VALUE="superSecret123!"

ROLE_NAME="/FullAccess"
AUTH_METHOD_NAME="/K8s/k8s-auth-leon-test"

# --- Checking Akeyless authentication method and role configuration ---

echo "--- Checking Akeyless authentication method ---"

AUTH_METHOD_OK=false
ROLE_OK=false
ASSOCIATION_OK=false

AUTH_JSON=""
ROLE_JSON=""

# --- Step 1: Check if auth method exists and its type ---

if akeyless get-auth-method --name "$AUTH_METHOD_NAME" >/dev/null 2>&1; then
    echo "Auth method $AUTH_METHOD_NAME exists"

    AUTH_JSON=$(akeyless get-auth-method --name "$AUTH_METHOD_NAME")

    if echo "$AUTH_JSON" | grep -q '"rules_type": "k8s"'; then
        echo "Auth method $AUTH_METHOD_NAME is of type Kubernetes"
        AUTH_METHOD_OK=true
    else
        echo "ERROR: Auth method $AUTH_METHOD_NAME exists but is NOT of type Kubernetes"
    fi

else
    echo "ERROR: Auth method $AUTH_METHOD_NAME does NOT exist"
fi


# --- Step 2: Check if role exists ---
echo "--- Checking role existence ---"

if akeyless get-role --name "$ROLE_NAME" >/dev/null 2>&1; then
    echo "Role $ROLE_NAME exists"
    ROLE_JSON=$(akeyless get-role --name "$ROLE_NAME")
    ROLE_OK=true
else
    echo "ERROR: Role $ROLE_NAME does NOT exist"
fi

# --- Step 3: Check association between role and auth method ---
echo "--- Checking role association with auth method ---"

AUTH_METHOD_NAME_NORMALIZED="${AUTH_METHOD_NAME#/}"

if [ "$AUTH_METHOD_OK" = true ] && [ "$ROLE_OK" = true ]; then
    if echo "$ROLE_JSON" | jq -e --arg AUTH "$AUTH_METHOD_NAME_NORMALIZED" \
        'any(.role_auth_methods_assoc[]; .auth_method_name == $AUTH)' >/dev/null; then

        echo "Role $ROLE_NAME is associated with auth method $AUTH_METHOD_NAME"
        ASSOCIATION_OK=true

    else
        echo "ERROR: Role $ROLE_NAME is NOT associated with auth method $AUTH_METHOD_NAME"
    fi
else
    echo "ERROR: Auth method and/or role are missing or invalid"
fi

# --- Final validation result ---
if [ "$AUTH_METHOD_OK" != true ] || [ "$ROLE_OK" != true ] || [ "$ASSOCIATION_OK" != true ]; then
    echo "ERROR: Required Akeyless configuration is missing or inconsistent."
    echo "Please create or fix the missing parameters first, then run this script again."
    exit 1
fi

echo "--- Checking Akeyless secret ---"

if akeyless get-secret-value --name "$SECRET_NAME" >/dev/null 2>&1; then
    echo "Secret $SECRET_NAME already exists. Skipping creation."
else
    echo "Secret $SECRET_NAME does not exist. Creating it..."

    akeyless create-secret \
        --name "$SECRET_NAME" \
        --value "$SECRET_VALUE"

    echo "Secret $SECRET_NAME created successfully"
fi

echo "Secret created successfully!"

# --- Checking Kubernetes namespace for Akeyless ---

echo "--- Checking Kubernetes namespace 'akeyless' ---"

if kubectl get namespace akeyless >/dev/null 2>&1; then
    echo "Namespace 'akeyless' already exists. Skipping creation."
else
    echo "Namespace 'akeyless' does not exist. Creating it..."

    kubectl create namespace akeyless
    kubectl label namespace akeyless name=akeyless

    echo "Namespace 'akeyless' created and labeled successfully"
fi

# --- Preparing Akeyless Injector using Helm ---

helm repo add akeyless https://akeylesslabs.github.io/helm-charts --force-update
helm repo update

# --- Checking Helm values file ---

echo "--- Checking Helm values file ---"

if [ -f values.yaml ]; then
    echo "values.yaml already exists. Printing key configuration values:"

    grep -E 'AKEYLESS_URL|AKEYLESS_ACCESS_TYPE|AKEYLESS_ACCESS_ID|AKEYLESS_API_GW_URL|AKEYLESS_K8S_AUTH_CONF_NAME' values.yaml | grep -v '^[[:space:]]*#'

else
    echo "values.yaml does not exist. Creating it..."

    helm show values akeyless/akeyless-secrets-injection > values.yaml

    echo "values.yaml created successfully"
fi