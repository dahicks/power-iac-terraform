variable "project" {
  type = string  
}

variable "name" {
  type = string
  default = "gateway"
}

variable "regions" {
  type = object ({
    us-east1 = object({ cidr = string})
    us-central1 = object({ cidr = string})
    us-west1 = object({ cidr = string})
  })

  default = {
    us-central1 = { cidr="10.128.0.0/20" }
    us-east1 = { cidr="10.142.0.0/20" }
    us-west1 = {cidr="10.138.0.0/20" } 
  }
}

locals {
  instance_groups = [ for k,v in var.regions: module.gateway[k].instance_groups ]
}
