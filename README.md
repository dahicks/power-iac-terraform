# Inititalize Terraform Provider

```
terraform init
```

# Generate Plan
```
terraform apply -auto-approve
```

# Grab Load Balancer IP from terraform output and browse
```
open http://$(terraform output -json | jq -r .load_balancer_ip.value)
```


# Destroy sandbox
```
terraform destroy -auto-approve
```