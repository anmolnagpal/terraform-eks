###_  __  _____  __   __  ____       _      ___   ____
##| |/ / | ____| \ \ / / |  _ \     / \    |_ _| |  _ \
##| ' /  |  _|    \ V /  | |_) |   / _ \    | |  | |_) |
##| . \  | |___    | |   |  __/   / ___ \   | |  |  _ <
##|_|\_\ |_____|   |_|   |_|     /_/   \_\ |___| |_| \_\

## keypair for ec2
resource "aws_key_pair" "main-key" {
  key_name   = "${var.key_name}"
  public_key = "${file("./it-admin-key.pub")}"
}
