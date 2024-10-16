#/bin/bash

# Variables
email="<your-email-address>"
namespace="default"
clusterIssuer="letsencrypt-application-gateway"

# Check if the cluster issuer already exists
result=$(kubectl get clusterissuer -n $namespace -o jsonpath="{.items[?(@.metadata.name=='$clusterIssuer')].metadata.name}")

# Load template
read -r -d '' template << EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-application-gateway
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory

    # You must replace this email address with your own.
    # Let's Encrypt will use this to contact you about expiring
    # certificates, and issues related to your account.
    email: $email

    privateKeySecretRef:
      # Secret resource used to store the account's private key.
      name: letsencrypt
    
    # Enable the HTTP-01 challenge provider
    # you prove ownership of a domain by ensuring that a particular
    # file is present at the domain
    solvers:
    - http01:
        ingress:
          ingressClassName: azure-application-gateway
EOF

if [[ -n $result ]]; then
  echo "[$clusterIssuer] cluster issuer already exists"
  exit
else
  # Create the cluster issuer 
  echo "[$clusterIssuer] cluster issuer does not exist"
  echo "Creating [$clusterIssuer] cluster issuer..."
  echo "$template" | kubectl apply -n $namespace -f -
fi