#!/bin/bash

export SERVICE_ACCOUNT="cicd-sa"
export SERVICE_ACCOUNT_NAMESPACE="kube-system"

kubectl create serviceaccount $SERVICE_ACCOUNT -n $SERVICE_ACCOUNT_NAMESPACE
kubectl create clusterrolebinding cicd-admin --clusterrole=cluster-admin --serviceaccount=$SERVICE_ACCOUNT_NAMESPACE:$SERVICE_ACCOUNT

# important: token is valid only for 48 hours
# if you want long-lived token - see here: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#manually-create-a-long-lived-api-token-for-a-serviceaccount
export SERVICE_ACCOUNT_TOKEN=$(kubectl create token $SERVICE_ACCOUNT -n $SERVICE_ACCOUNT_NAMESPACE --duration=48h)

export CERT=$(kubectl get configmap -n default kube-root-ca.crt -o jsonpath="{['data']['ca\.crt']}" | base64)
export CLUSTER_URL=$(kubectl config view --minify -o 'jsonpath={.clusters[0].cluster.server}')
export CLUSTER_NAME=$(kubectl config view --minify -o 'jsonpath={.clusters[0].name}')

cat << EOF > kubeconfig-sa.yaml
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: $CERT
    server: $CLUSTER_URL
  name: $CLUSTER_NAME
contexts:
- context:
    cluster: $CLUSTER_NAME
    namespace: $SERVICE_ACCOUNT_NAMESPACE
    user: $SERVICE_ACCOUNT
  name: $CLUSTER_NAME-ctx
current-context: $CLUSTER_NAME-ctx
kind: Config
users:
- name: $SERVICE_ACCOUNT
  user:
    token: $SERVICE_ACCOUNT_TOKEN
EOF