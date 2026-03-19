#!/bin/bash

set -e

# --- ANSI Color Codes ---
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

# --- Variables ---
SECRET_NAME="/K8s/InjectorDemo/InjectorSecret"
SECRET_VALUE="superSecret123@"


ROLE_NAME="/FullAccess"
AUTH_METHOD_NAME="/K8s/k8s-auth-leon-test"

# --- Checking Akeyless authentication method and role configuration ---

printf "\n--- Checking Akeyless authentication method ---\n"

AUTH_METHOD_OK=false
ROLE_OK=false
ASSOCIATION_OK=false

AUTH_JSON=""
ROLE_JSON=""

# --- Step 1: Check if auth method exists and its type ---

if akeyless get-auth-method --name "$AUTH_METHOD_NAME" >/dev/null 2>&1; then
    printf "${GREEN}Auth method %s exists.${NC}\n" "$AUTH_METHOD_NAME"

    AUTH_JSON=$(akeyless get-auth-method --name "$AUTH_METHOD_NAME")

    if echo "$AUTH_JSON" | grep -q '"rules_type": "k8s"'; then
        printf "${GREEN}Auth method %s is of type Kubernetes.${NC}\n" "$AUTH_METHOD_NAME"
        AUTH_METHOD_OK=true
    else
        printf "${RED}ERROR: Auth method %s exists but is NOT of type Kubernetes.${NC}\n" "$AUTH_METHOD_NAME"
    fi
else
    printf "${RED}ERROR: Auth method %s does NOT exist.${NC}\n" "$AUTH_METHOD_NAME"
fi


# --- Step 2: Check if role exists ---
printf "\n--- Checking role existence ---\n"

if akeyless get-role --name "$ROLE_NAME" >/dev/null 2>&1; then
    printf "${GREEN}Role %s exists.${NC}\n" "$ROLE_NAME"
    ROLE_JSON=$(akeyless get-role --name "$ROLE_NAME")
    ROLE_OK=true
else
    printf "${RED}ERROR: Role %s does NOT exist.${NC}\n" "$ROLE_NAME"
fi

# --- Step 3: Check association between role and auth method ---
printf "\n--- Checking role association with auth method ---\n"

AUTH_METHOD_NAME_NORMALIZED="${AUTH_METHOD_NAME#/}"

if [ "$AUTH_METHOD_OK" = true ] && [ "$ROLE_OK" = true ]; then
    if echo "$ROLE_JSON" | jq -e --arg AUTH "$AUTH_METHOD_NAME_NORMALIZED" \
        'any(.role_auth_methods_assoc[]; .auth_method_name == $AUTH)' >/dev/null; then

        printf "${GREEN}Role %s is associated with auth method %s.${NC}\n" "$ROLE_NAME" "$AUTH_METHOD_NAME"
        ASSOCIATION_OK=true

    else
        printf "${RED}ERROR: Role %s is NOT associated with auth method %s.${NC}\n" "$ROLE_NAME" "$AUTH_METHOD_NAME"
    fi
else
    printf "${RED}ERROR: Auth method and/or role are missing or invalid.${NC}\n"
fi

# --- Final validation result ---
if [ "$AUTH_METHOD_OK" != true ] || [ "$ROLE_OK" != true ] || [ "$ASSOCIATION_OK" != true ]; then
    printf "${RED}ERROR: Required Akeyless configuration is missing or inconsistent.${NC}\n"
    printf "${YELLOW}Please create or fix the missing parameters first, then run this script again.${NC}\n"
    exit 1
fi

printf "\n--- Checking Akeyless secret ---\n"

if akeyless get-secret-value --name "$SECRET_NAME" >/dev/null 2>&1; then
    printf "${YELLOW}Secret %s already exists. Skipping creation.${NC}\n" "$SECRET_NAME"
else
    printf "${GREEN}Secret %s does not exist. Creating it...${NC}\n" "$SECRET_NAME"

    akeyless create-secret \
        --name "$SECRET_NAME" \
        --value "$SECRET_VALUE"

    printf "${GREEN}Secret %s created successfully.${NC}\n" "$SECRET_NAME"
fi

printf "${GREEN}Secret check completed successfully.${NC}\n"

# --- Checking Kubernetes namespace for Akeyless ---

printf "\n--- Checking Kubernetes namespace 'akeyless' ---\n"

if kubectl get namespace akeyless >/dev/null 2>&1; then
    printf "${YELLOW}Namespace 'akeyless' already exists. Skipping creation.${NC}\n"
else
    printf "${GREEN}Namespace 'akeyless' does not exist. Creating it...${NC}\n"

    kubectl create namespace akeyless
    kubectl label namespace akeyless name=akeyless

    printf "${GREEN}Namespace 'akeyless' created and labeled successfully.${NC}\n"
fi

# --- Preparing Akeyless Injector using Helm ---

printf "\n--- Preparing Akeyless Injector Helm repository ---\n"

helm repo add akeyless https://akeylesslabs.github.io/helm-charts --force-update
helm repo update

# --- Checking Helm values file ---

printf "\n--- Checking Helm values file ---\n"

if [ -f values.yaml ]; then
    printf "${YELLOW}values.yaml already exists. Printing key configuration values:${NC}\n"

    grep -E 'AKEYLESS_URL|AKEYLESS_ACCESS_TYPE|AKEYLESS_ACCESS_ID|AKEYLESS_API_GW_URL|AKEYLESS_K8S_AUTH_CONF_NAME' values.yaml | grep -v '^[[:space:]]*#'

else
    printf "${GREEN}values.yaml does not exist. Creating it...${NC}\n"

    helm show values akeyless/akeyless-secrets-injection > values.yaml

    printf "${GREEN}values.yaml created successfully.${NC}\n"
fi



#git add . && git commit -m "Update injector script with colored output" && git push