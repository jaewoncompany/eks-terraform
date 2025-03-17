module "efs" {
    count = var.enable_efs_csi_dirver ? 1 :0
    source = "terraform-aws-modules/efs/aws"

    name = "${var.prefix}-efs"
    encrypted = true

    attach_policy                      = true
    bypass_policy_lockout_safety_check = false

      mount_targets = {
    "${var.region}a" = {
      subnet_id = module.vpc.private_subnets[0]
    }
    "${var.region}c" = {
      subnet_id = module.vpc.private_subnets[1]
    }
  }
  security_group_description = "Example EFS security group"
  security_group_vpc_id      = module.vpc.vpc_id
  security_group_rules = {
    vpc = {
      # relying on the defaults provided for EFS/NFS (2049/TCP + ingress)
      description = "NFS ingress from VPC private subnets"
      cidr_blocks = [module.vpc.vpc_cidr_block]
    }
  }
}