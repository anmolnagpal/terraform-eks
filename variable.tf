##__     ___    ____  ___    _    ____  _     _____
##\ \   / / \  |  _ \|_ _|  / \  | __ )| |   | ____|
###\ \ / / _ \ | |_) || |  / _ \ |  _ \| |   |  _|
####\ V / ___ \|  _ < | | / ___ \| |_) | |___| |___
#####\_/_/   \_\_| \_\___/_/   \_\____/|_____|_____|

variable "region" {
  default     = "us-east-1"
  description = "Region"
}

variable "vpc" {
  type = "map"
  default = {
    main          = "10.0.0.0/16"
    subnet-1a-prv = "10.0.32.0/20"
    subnet-1c-prv = "10.0.96.0/20"
  }
}

variable "env" {
  default = "live"
}

variable "external-ip" {
  default = "5.194.139.128/32"
}

variable "nodes_defaults" {
  description = "Default values for target groups as defined by the list of maps."
  type        = "map"

  default = {
    name                 = "eks-nodes"    # Name for the eks workers.
    ami_id               = "ami-dea4d5a1" # AMI ID for the eks workers. If none is provided, Terraform will searchfor the latest version of their EKS optimized worker AMI.
    asg_desired_capacity = "1"            # Desired worker capacity in the autoscaling group.
    asg_max_size         = "3"            # Maximum worker capacity in the autoscaling group.
    asg_min_size         = "1"            # Minimum worker capacity in the autoscaling group.
    instance_type        = "m4.large"     # Size of the workers instances.
    key_name             = "eks-key"      # The key name that should be used for the instances in the autoscaling group
    ebs_optimized        = true           # sets whether to use ebs optimization on supported types.
    public_ip            = false          # Associate a public ip address with a worker
  }
}

variable "cluster_defaults" {
  description = "Default values for target groups as defined by the list of maps."
  type        = "map"

  default = {
    name = "eks-cluster" # Name for the eks cluster.
  }
}
