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
