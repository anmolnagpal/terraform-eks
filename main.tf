##__     ______   ____
##\ \   / /  _ \ / ___|
###\ \ / /| |_) | |
####\ V / |  __/| |___
#####\_/  |_|    \____|

# Create a VPC to launch our instances into
resource "aws_vpc" "vpc" {
  cidr_block = "${var.vpc}"

  tags {
    Name = "${var.env}-eks-cluster"
    Environment  = "${var.env}"
    ManagedBy = "Terraform"
  }
}

# ____  ____   _____     _____ ____  _____ ____
#|  _ \|  _ \ / _ \ \   / /_ _|  _ \| ____|  _ \
#| |_) | |_) | | | \ \ / / | || | | |  _| | |_) |
#|  __/|  _ <| |_| |\ V /  | || |_| | |___|  _ <
#|_|   |_| \_\\___/  \_/  |___|____/|_____|_| \_\

# Specify the provider and access details
provider "aws" {
  shared_credentials_file = "./credentials"
  profile                 = "live"
  region                  = "${var.region}"
}

# Using these data sources allows the configuration to be
# generic for any region.
data "aws_region" "current" {}

data "aws_availability_zones" "available" {}

# Not required: currently used in conjuction with using
# icanhazip.com to determine local laptop external IP
# to open EC2 Security Group access to the Kubernetes cluster.
# See laptop-external-ip.tf for additional information.
provider "http" {}


##___    ____  __        __
#|_ _|  / ___| \ \      / /
##| |  | |  _   \ \ /\ / /
##| |  | |_| |   \ V  V /
#|___|  \____|    \_/\_/

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.env}-igw"
    Environment = "${var.env}"
    ManagedBy = "Terraform"
  }
}


##___ ____
##|_ _|  _ \
##| || |_) |
##| ||  __/
#|___|_|

#
# laptop External IP
#
# This configuration is not required and is
# only provided as an example to easily fetch
# the external IP of your local laptop to
# configure inbound EC2 Security Group access
# to the Kubernetes cluster.
#

data "http" "laptop-external-ip" {
  url = "http://icanhazip.com"
}

# Override with variable or hardcoded value if necessary
locals {
  laptop-external-cidr = "${chomp(data.http.laptop-external-ip.body)}/32"
}
