###___ ____
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
