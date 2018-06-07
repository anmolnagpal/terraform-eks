##__     ___    ____  ___    _    ____  _     _____
##\ \   / / \  |  _ \|_ _|  / \  | __ )| |   | ____|
###\ \ / / _ \ | |_) || |  / _ \ |  _ \| |   |  _|
####\ V / ___ \|  _ < | | / ___ \| |_) | |___| |___
#####\_/_/   \_\_| \_\___/_/   \_\____/|_____|_____|

variable "cluster-name" {
  default = "terraform-eks-demo"
  type    = "string"
}

variable "region" {
  default     = "us-east-1"
  description = "Region"
}

variable "key_name" {
  default     = "it-admin-key"
  description = "Default AWS Key"
}

variable "ami" {
  default = "ami-dea4d5a1"
}

variable "vpc" {
  default = "10.0.0.0/16"
}

variable "env" {
  default = "live"
}
