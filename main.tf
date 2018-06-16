##__     ______   ____
##\ \   / /  _ \ / ___|
###\ \ / /| |_) | |
####\ V / |  __/| |___
#####\_/  |_|    \____|

# Create a VPC to launch our instances into
resource "aws_vpc" "vpc" {
  cidr_block = "${var.vpc["main"]}"

  tags {
    Name        = "${var.env}-vpc"
    Environment = "${var.env}"
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
    Name        = "${var.env}-igw"
    Environment = "${var.env}"
  }
}

## keypair for ec2
resource "aws_key_pair" "eks-prod-key" {
  key_name   = "${var.nodes_defaults["key_name"]}"
  public_key = "${file("./it-admin-key.pub")}"
}

