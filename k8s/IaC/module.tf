module "nginx_ingress_controller" {
    source = "./nginx_ingress_controller"
    prefix = var.prefix
    oidc_provider_arn = module.eks.oidc_provider_arn
    nlb_sg_id = aws_security_group.lb-sg.id
    depends_on = [ module.eks, helm_release.aws-lb-controller ]
    
}

module "ebs_csi_dirver" {
  count = var.enable_efs_csi_dirver ? 1 : 0

  source = "./ebs_csi_driver"
  prefix = var.prefix
  oidc_provider_arn = module.eks.oidc_provider_arn
  node_group_id = split(":", module.eks.eks_managed_node_groups.addon_nodes.node_group_id)[1]

  depends_on = [ module.eks ]
}

module "efs_csi_dirver" {
  count = var.enable_efs_csi_dirver ? 1 : 0
  
  source = "./efs_csi_driver"
  prefix = var.prefix
  oidc_provider_arn = module.eks.oidc_provider_arn
  node_group_id = split(":", module.eks.eks_managed_node_groups.addon_nodes.node_group_id)[1]

  depends_on = [ module.eks ]
}

module "prometheus" {
  count = var.enable_prometheus ? 1 : 0
  source = "./prometheus"

  depends_on = [ module.eks, module.nginx_ingress_controller]
}


module "karpenter" {
  source = "./karpenter"
  prefix = var.prefix
  oidc_provider_arn = module.eks.oidc_provider_arn
  node_group_id = split(":", module.eks.eks_managed_node_groups.addon_nodes.node_group_id)[1]
  cluster_name = module.eks.cluster_name
  cluster_endpoint = module.eks.cluster_endpoint

  providers = {
    aws = aws
    aws.virginia = aws.virginia
  }

  depends_on = [ module.eks ]
}

module "argocd" {
  count = var.enable_argocd ? 1:0
  source = "./argocd"
  depends_on = [ module.eks, module.nginx_ingress_controller ]
}