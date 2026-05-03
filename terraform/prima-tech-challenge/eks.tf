resource "aws_iam_role" "eks_cluster" {
  name = "eks-cluster"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_eks_cluster" "eks_cluster" {
  name     = var.project
  role_arn = aws_iam_role.eks_cluster.arn
  version  = "1.35"

  vpc_config {
    subnet_ids = aws_subnet.public[*].id
  }

  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
}

resource "aws_iam_role" "eks_nodes" {
  name = "eks-nodes"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.eks_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_eks_node_group" "eks_cluster" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.project}-nodes"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = aws_subnet.public[*].id
  instance_types  = ["t3.small"]

  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 2
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
  ]
}

resource "aws_iam_openid_connect_provider" "eks" {
  url            = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
  client_id_list = ["sts.amazonaws.com"]

  depends_on = [aws_eks_cluster.eks_cluster]
}

resource "aws_eks_access_entry" "nodes" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = aws_iam_role.eks_nodes.arn
  type          = "EC2_LINUX"
}

resource "aws_eks_access_entry" "terraform_user" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = "arn:aws:iam::803871048799:user/prima-tech-challenge-terraform"
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "terraform_user" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = "arn:aws:iam::803871048799:user/prima-tech-challenge-terraform"
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.terraform_user]
}
