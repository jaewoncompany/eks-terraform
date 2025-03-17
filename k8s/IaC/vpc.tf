module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.prefix}-vpc"
  cidr = "192.168.0.0/16"

  azs = ["${var.region}a", "${var.region}c"]
  public_subnets = ["192.168.10.0/24", "192.168.20.0/24"]
  private_subnets = ["192.168.11.0/24", "192.168.21.0/24"]

  map_public_ip_on_launch = true
  enable_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb" = 1
  }
  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "karpenter.sh/discovery" = "${var.cluster_name}"
  }
}