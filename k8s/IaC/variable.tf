variable "region" {
  default = "ap-northeast-2"
}

variable "awscli_profile" {
  default = "default"
}

variable "prefix" {
  default = "jjw"
}

variable "cluster_name" {
  default = "jaewon-cluster"
}

variable "enable_ebs_csi_dirver" {
  type = bool
  default = false

}

variable "enable_efs_csi_dirver" {
  type = bool
  default = false
  
}

variable "enable_prometheus" {
  type = bool
  default = false
}

variable "enable_argocd" {
  type = bool
  default = false 
}