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
