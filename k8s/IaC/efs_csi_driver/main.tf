module "efs_csi_dirver-irsa-role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = "${var.prefix}-efs-csi-driver-sa-role"

  attach_efs_csi_policy = true

  attach_load_balancer_controller_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["kube-system:efs-csi-driver-sa"]
    }
  }
}

resource "helm_release" "efs-efs_csi_dirver" {
  namespace = "kube-system"
  repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver"
  chart = "aws-efs-csi-driver"
  name = "aws-efs-csi-driver"

  set {
    name = "controller.serviceAccount.create"
    value = true
  }
  set {
    name = "controller.serviceAccount.name"
    value = "efs-csi-driver-sa"
  }

  set {
    name = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.efs_csi_dirver-irsa-role.iam_role_arn
  }

  set {
    name = "controller.serviceAccount.name"
    value = "efs-csi-driver-sa"
  }
  set {
    name = "controller.nodeSelector.eks\\.amazonaws\\.com/nodegroup"
    value = var.node_group_id
  }

  set {
    name = "controller.replicaCount"
    value = 1
  }



}