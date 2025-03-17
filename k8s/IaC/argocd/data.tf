data "kubernetes_service" "nginx_ingress_contoller" {
    metadata {
      name = "ingress-nginx-contoller"
      namespace = "ingress-nginx"
    }
  
}