resource "aws_security_group" "worker_node_sg" {
    vpc_id = module.vpc.vpc_id
  ingress = [{
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow all"
    from_port = 0
    to_port = 0
    protocol = "-1"
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = []
    self = false
  }]

    egress = [{
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow all"
    from_port = 0
    to_port = 0
    protocol = "-1"
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = []
    self = false
    }]

    tags = {
      "Name" = "${var.prefix}-addon-sg"
    }
}

module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name    = var.cluster_name
  cluster_version = "1.31"

  cluster_endpoint_public_access = true

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.public_subnets
  control_plane_subnet_ids = module.vpc.public_subnets

  eks_managed_node_group_defaults = {
    instance_types = ["t3.medium"]
  }

  eks_managed_node_groups = {
    addon_nodes = {
      vpc_security_group_ids = [module.eks.node_security_group_id, aws_security_group.worker_node_sg.id] 
      ami_type               = "AL2023_x86_64_STANDARD"
      desired_size           = 2
      min_size               = 2
      max_size               = 4
    }
  }

  cluster_addons = {
    coredns = {}
    eks-pod-identity-agent = {}
    kube-proxy = {}
    vpc-cni = {}
  }

  enable_cluster_creator_admin_permissions = true

  tags = {
    "karpenter.sh/discovery" = "${var.prefix}-k8s-cluster"
  }

  depends_on = [module.vpc]
}

resource "aws_eks_access_entry" "bastion_eks_access" {
  cluster_name = module.eks.cluster_name
  principal_arn = aws_iam_role.bastion_role.arn
}

resource "aws_eks_access_policy_association" "bastion_eks_access_policy" {
  cluster_name = module.eks.cluster_name
  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = aws_iam_role.bastion_role.arn

  access_scope {
    type = "cluster"
  }
}