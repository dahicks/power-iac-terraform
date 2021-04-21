## Pre-requisites

This demo leverages the following set of tools.  Links have been provided for instructions on installation.

1. [Terraform](https://www.terraform.io/downloads.html)
2. [jq](https://stedolan.github.io/jq/download/)
3. [gcloud](https://cloud.google.com/sdk/docs/quickstart)

We are leveraging [Google Cloud Platform](https://cloud.google.com/free/) to deploy our infrastructure resources.  You'll need to have access to a Google Cloud Platform project in order to complete the exercise.

### Inititalize Terraform Provider

```
cd environments/gateway
terraform init
```

### Set Google Project ID for Provider
This will default the active project in your gcloud configuration
```
export TF_VAR_project=[YOUR GOOGLE CLOUD PROJECT ID]
```

### Generate Plan
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
curl -H "Host: echo.service.internal" http://${LB_IP}
```

# Clean Up
```
terraform destroy -auto-approve
```