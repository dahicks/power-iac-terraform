Pre-requisites

This demo leverages the following set of tools.  Links have been provided for instructions on installation

1. [Terraform](https://www.terraform.io/downloads.html)
2. [jq](https://stedolan.github.io/jq/download/)
3. [gcloud](https://cloud.google.com/sdk/docs/quickstart)

# Inititalize Terraform Provider

```
cd  environments/gateway
terraform init
```

# Set Google Project ID for Provider
```
export TF_VAR_project=`gcloud config list --format="value(core.project)"`
```

# Generate Plan
```
terraform plan
```

# Apply Changes
```
terraform apply -auto-approve
```

# Grab Load Balancer IP from Terraform output and browse
```
LB_IP=`terraform output -json | jq -r .load_balancer.value`
while true; do echo 'waiting for lb to come up...'; nc -w1 ${LB_IP} 80; if [[ $? > 0 ]]; then continue; else break; fi; sleep 5; done
open http://${LB_IP}
```

# Clean Up
```
terraform destroy -auto-approve
```