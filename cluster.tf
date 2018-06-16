####____ _    _   _ ____ _____ _____ ____
###/ ___| |  | | | / ___|_   _| ____|  _ \
##| |   | |  | | | \___ \ | | |  _| | |_) |
#| |___| |__| |_| |___) || | | |___|  _ <
#\____|_____\___/|____/ |_| |_____|_| \_\

resource "aws_security_group" "eks-cluster" {
  name        = "eks-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = "${aws_vpc.vpc.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name      = "${var.env}-eks-cluster"
    Env       = "${var.env}"
    ManagedBy = "Terraform"
  }
}

resource "aws_security_group_rule" "cluster-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.eks-cluster.id}"
  source_security_group_id = "${aws_security_group.eks-nodes.id}"
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "cluster-ingress-laptop-https" {
  cidr_blocks       = ["${var.external-ip}"]
  description       = "Allow laptop to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.eks-cluster.id}"
  to_port           = 443
  type              = "ingress"
}

resource "aws_eks_cluster" "eks-cluster" {
  name     = "${var.cluster-name}"
  role_arn = "${aws_iam_role.eks-cluster.arn}"

  vpc_config {
    security_group_ids = ["${aws_security_group.eks-cluster.id}"]

    subnet_ids = [
      "${aws_subnet.subnet-1a-prv.*.id}",
      "${aws_subnet.subnet-1c-prv.*.id}",
    ]
  }

  depends_on = [
    "aws_iam_role_policy_attachment.k8s-cluster-AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.k8s-cluster-AmazonEKSServicePolicy",
  ]
}
