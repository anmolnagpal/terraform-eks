###____ _    _   _ ____ _____ _____ ____
##/ ___| |  | | | / ___|_   _| ____|  _ \
#| |   | |  | | | \___ \ | | |  _| | |_) |
#| |___| |__| |_| |___) || | | |___|  _ <
#\____|_____\___/|____/ |_| |_____|_| \_\

resource "aws_iam_role" "eks-cluster" {
  name = "eks-cluster"
  path = "./"
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

###_   _  ___  ____  _____ ____
##| \ | |/ _ \|  _ \| ____/ ___|
##|  \| | | | | | | |  _| \___ \
##| |\  | |_| | |_| | |___ ___) |
##|_| \_|\___/|____/|_____|____/

resource "aws_iam_role" "eks-node" {
  name = "eks-node"
  path = "./"
  assume_role_policy = "${file("./json/node-role-policy.json")}"
}

resource "aws_iam_role_policy_attachment" "eks-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.eks-node.name}"
}

resource "aws_iam_role_policy_attachment" "eks-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.eks-node.name}"
}

resource "aws_iam_role_policy_attachment" "eks-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.eks-node.name}"
}
