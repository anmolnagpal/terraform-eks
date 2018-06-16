##_   _  ___  ____  _____ ____
#| \ | |/ _ \|  _ \| ____/ ___|
#|  \| | | | | | | |  _| \___ \
#| |\  | |_| | |_| | |___ ___) |
#|_| \_|\___/|____/|_____|____/

resource "aws_iam_instance_profile" "eks-nodes" {
  name = "${var.nodes_defaults["name"]}"
  role = "${aws_iam_role.eks-nodes.name}"
}

resource "aws_security_group" "eks-nodes" {
  name        = "${var.nodes_defaults["name"]}-sg"
  description = "Security group for all nodes in the cluster"
  vpc_id      = "${aws_vpc.vpc.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "${var.nodes_defaults["name"]}-sg"
    Environment = "${var.env}"
  }
}

resource "aws_security_group_rule" "ingress-self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.eks-nodes.id}"
  source_security_group_id = "${aws_security_group.eks-nodes.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "ingress-cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.eks-nodes.id}"
  source_security_group_id = "${aws_security_group.eks-cluster.id}"
  to_port                  = 65535
  type                     = "ingress"
}

# EKS currently documents this required userdata for EKS worker nodes to
# properly configure Kubernetes applications on the EC2 instance.
# We utilize a Terraform local here to simplify Base64 encoding this
# information into the AutoScaling Launch Configuration.
# More information: https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-06-05/amazon-eks-nodegroup.yaml
locals {
  eks-nodes-userdata = <<USERDATA
#!/bin/bash -xe
CA_CERTIFICATE_DIRECTORY=/etc/kubernetes/pki
CA_CERTIFICATE_FILE_PATH=$CA_CERTIFICATE_DIRECTORY/ca.crt
mkdir -p $CA_CERTIFICATE_DIRECTORY
echo "${aws_eks_cluster.eks-cluster.certificate_authority.0.data}" | base64 -d >  $CA_CERTIFICATE_FILE_PATH
INTERNAL_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
sed -i s,MASTER_ENDPOINT,${aws_eks_cluster.eks-cluster.endpoint},g /var/lib/kubelet/kubeconfig
sed -i s,CLUSTER_NAME,${var.cluster_defaults["name"]},g /var/lib/kubelet/kubeconfig
sed -i s,REGION,${data.aws_region.current.name},g /etc/systemd/system/kubelet.service
sed -i s,MAX_PODS,20,g /etc/systemd/system/kubelet.service
sed -i s,MASTER_ENDPOINT,${aws_eks_cluster.eks-cluster.endpoint},g /etc/systemd/system/kubelet.service
sed -i s,INTERNAL_IP,$INTERNAL_IP,g /etc/systemd/system/kubelet.service
DNS_CLUSTER_IP=10.100.0.10
if [[ $INTERNAL_IP == 10.* ]] ; then DNS_CLUSTER_IP=172.20.0.10; fi
sed -i s,DNS_CLUSTER_IP,$DNS_CLUSTER_IP,g /etc/systemd/system/kubelet.service
sed -i s,CERTIFICATE_AUTHORITY_FILE,$CA_CERTIFICATE_FILE_PATH,g /var/lib/kubelet/kubeconfig
sed -i s,CLIENT_CA_FILE,$CA_CERTIFICATE_FILE_PATH,g  /etc/systemd/system/kubelet.service
systemctl daemon-reload
systemctl restart kubelet kube-proxy
USERDATA
}

resource "aws_launch_configuration" "config" {
  associate_public_ip_address = true
  iam_instance_profile        = "${aws_iam_instance_profile.eks-nodes.name}"
  image_id                    = "${var.nodes_defaults["ami_id"]}"
  instance_type               = "${var.nodes_defaults["instance_type"]}"
  key_name                    = "${var.nodes_defaults["key_name"]}"
  name_prefix                 = "eks-config"
  security_groups             = ["${aws_security_group.eks-nodes.id}"]
  user_data_base64            = "${base64encode(local.eks-nodes-userdata)}"
  ebs_optimized               = "${var.nodes_defaults["ebs_optimized"]}"

  lifecycle {
    create_before_destroy = true
  }

  root_block_device {
    delete_on_termination = true
  }
}

resource "aws_autoscaling_group" "autoscaling-group" {
  desired_capacity     = "${var.nodes_defaults["asg_desired_capacity"]}"
  launch_configuration = "${aws_launch_configuration.config.id}"
  max_size             = "${var.nodes_defaults["asg_max_size"]}"
  min_size             = "${var.nodes_defaults["asg_min_size"]}"
  name                 = "${var.nodes_defaults["name"]}-asg"

  vpc_zone_identifier = [
    "${aws_subnet.subnet-1a-prv.*.id}",
    "${aws_subnet.subnet-1c-prv.*.id}",
  ]

  tag {
    key                 = "Name"
    value               = "${var.nodes_defaults["name"]}-asg"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster_defaults["name"]}"
    value               = "owned"
    propagate_at_launch = true
  }
}

resource "aws_iam_role" "eks-nodes" {
  name               = "${var.nodes_defaults["name"]}"
  path               = "/"
  assume_role_policy = "${file("./json/nodes-role-policy.json")}"
}

resource "aws_iam_role_policy_attachment" "eks-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.eks-nodes.name}"
}

resource "aws_iam_role_policy_attachment" "eks-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.eks-nodes.name}"
}

resource "aws_iam_role_policy_attachment" "eks-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.eks-nodes.name}"
}
