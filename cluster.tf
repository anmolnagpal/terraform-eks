####____ _    _   _ ____ _____ _____ ____
###/ ___| |  | | | / ___|_   _| ____|  _ \
##| |   | |  | | | \___ \ | | |  _| | |_) |
#| |___| |__| |_| |___) || | | |___|  _ <
#\____|_____\___/|____/ |_| |_____|_| \_\

resource "aws_security_group" "eks-cluster" {
  name        = "${var.cluster_defaults["name"]}"
  description = "Cluster communication with worker nodes"
  vpc_id      = "${aws_vpc.vpc.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "${var.cluster_defaults["name"]}-sg"
    Environment = "${var.env}"
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
  name     = "${var.cluster_defaults["name"]}"
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

resource "aws_iam_role" "eks-cluster" {
  name               = "${var.cluster_defaults["name"]}"
  path               = "/"
  assume_role_policy = "${file("./json/cluster-role-policy.json")}"
}

resource "aws_iam_role_policy_attachment" "k8s-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.eks-cluster.name}"
}

resource "aws_iam_role_policy_attachment" "k8s-cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.eks-cluster.name}"
}
