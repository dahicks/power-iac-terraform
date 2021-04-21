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

### Apply Changes
```
terraform apply -auto-approve
```

### Grab Load Balancer IP from Terraform output and browse

In the following code snippet, we'll retrieve the external load balancer IP from the Terraform state and use it to make an HTTP request to our upstream service through the newly built API Gateway.  

> Note: It can take 5-10 minutes for the Load Balancer to come up.  Until that happens, you may receive 4XX/5XX servers.

```
LB_IP=`terraform output -json | jq -r .load_balancer.value`
while true; do curl -H "Host: echo.service.internal" http://${LB_IP}; printf "\n\n"; sleep 10; done
```

### Clean Up

The following command will tear down all resources created/managed in Terraform's state.
```
terraform destroy -auto-approve
```