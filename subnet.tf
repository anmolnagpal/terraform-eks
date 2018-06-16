##____  _   _ ____  _   _ _____ _____
#/ ___|| | | | __ )| \ | | ____|_   _|
#\___ \| | | |  _ \|  \| |  _|   | |
##___) | |_| | |_) | |\  | |___  | |
#|____/ \___/|____/|_| \_|_____| |_|

# Subnets with AZ-A
resource "aws_subnet" "subnet-1a-prv" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${var.vpc["subnet-1a-prv"]}"
  availability_zone = "${var.region}a"

  tags {
    Name        = "${var.env}-subnet-1a-prv"
    Environment = "${var.env}"
  }
}

##  route table association
resource "aws_route_table" "rt-1a-prv" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags {
    Name        = "${var.env}-rt-app-1a-prv"
    Environment = "${var.env}"
  }
}

# route table association Zone-A
resource "aws_route_table_association" "rt-1a-prv" {
  subnet_id      = "${aws_subnet.subnet-1a-prv.id}"
  route_table_id = "${aws_route_table.rt-1a-prv.id}"
}

##____  _   _ ____  _   _ _____ _____
#/ ___|| | | | __ )| \ | | ____|_   _|
#\___ \| | | |  _ \|  \| |  _|   | |
##___) | |_| | |_) | |\  | |___  | |
#|____/ \___/|____/|_| \_|_____| |_|

# Subnets with AZ-C
resource "aws_subnet" "subnet-1c-prv" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${var.vpc["subnet-1c-prv"]}"
  availability_zone = "${var.region}c"

  tags {
    Name        = "${var.env}-subnet-1c-prv"
    Environment = "${var.env}"
  }
}

##  route table association
resource "aws_route_table" "subnet-1c-prv" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags {
    Name        = "${var.env}-rt-1c-prv"
    Environment = "${var.env}"
  }
}

# route table association Zone-C
resource "aws_route_table_association" "subnet-1c-prv" {
  subnet_id      = "${aws_subnet.subnet-1c-prv.id}"
  route_table_id = "${aws_route_table.subnet-1c-prv.id}"
}
