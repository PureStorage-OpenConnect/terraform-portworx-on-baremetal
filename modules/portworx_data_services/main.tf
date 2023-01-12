data "http" "get_token" {
  url = "https://prod.pds.portworx.com/api/service-accounts/${var.account_id}/token"       #${local.extd.cluster-id}
  request_headers = {
    Accept = "application/json"
    Authorization = "Bearer ${var.pds_token}"
  }
}

data "http" "get_version" {
  url = "https://prod.pds.portworx.com/api/metadata"
  request_headers = {
    Accept = "application/json"
    Authorization = "Bearer ${var.pds_token}"
  }
}


locals {
auth_token = jsondecode("${data.http.get_token.response_body}").token
helm_version = jsondecode("${data.http.get_version.response_body}").helm_chart_version
}


resource "null_resource" "pds_setup" {
  provisioner "local-exec" {
     command = <<-EOT
       echo "Setting up PDS. It will take several minutes."
       kubectl --kubeconfig=../../modules/k8s_setup/kube-config-file create namespace pds-ns
       kubectl --kubeconfig=../../modules/k8s_setup/kube-config-file label namespaces pds-ns pds.portworx.com/available=true --overwrite=true
       helm --kubeconfig=../../modules/k8s_setup/kube-config-file install --create-namespace --namespace=pds-system pds pds-target --repo=https://portworx.github.io/pds-charts --version=${local.helm_version} --set tenantId=${var.tenant_id} --set clusterName=${var.pds_name} --set bearerToken=${local.auth_token} --set apiEndpoint=https://prod.pds.portworx.com/api
     EOT
     interpreter = ["/bin/bash", "-c"]
     working_dir = path.module
   }
  provisioner "local-exec" {
    when    = destroy
    on_failure = continue
    command = <<-EOT
       echo "Deleting PDS. It will take several minutes."
       kubectl --kubeconfig=../../modules/k8s_setup/kube-config-file delete crd $(kubectl --kubeconfig=../../modules/k8s_setup/kube-config-file api-resources --api-group=backups.pds.io -o name | tr '\n' ' ') --wait
       kubectl --kubeconfig=../../modules/k8s_setup/kube-config-file delete crd $(kubectl --kubeconfig=../../modules/k8s_setup/kube-config-file api-resources --api-group=deployments.pds.io -o name | tr '\n' ' ') --wait
       helm --kubeconfig=../../modules/k8s_setup/kube-config-file delete -n pds-system pds
       kubectl --kubeconfig=../../modules/k8s_setup/kube-config-file delete namespace pds-system pds-ns
     EOT
     interpreter = ["/bin/bash", "-c"]
     working_dir = path.module
   }
}
