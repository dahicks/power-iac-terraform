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

variable "name" {
  default = "api-gtw-demo"
}

variable "project_id" {
  type = string  
}