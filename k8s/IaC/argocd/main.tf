resource "helm_release" "argocd" {
  name = "argocd"
  chart = "argo-cd"

  repository = "https://aroproj.github.io/argo-helm"
  namespace = "argocd"
  create_namespace = true

  values = [ 
    <<EOT
global:
    domain: ${data.kubernetes_service.nginx_ingress_contoller.status[0].load_balancer[0].ingress[0].hostname}
configs:
    params:
        server.insecure: true
        server.basehref: /argocd
        server/rootpath: /argocd
server:
    ingress:
        enable: true
        ingressClassName: "ngnix"
        path: /argocd
EOT
    ]
}