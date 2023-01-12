resource "null_resource" "kube_setup" {
  provisioner "local-exec" {
     command = <<-EOT
       echo "Setting up k8s cluster. It will take several minutes."
       ../../scripts/setup-cluster.sh
     EOT
     interpreter = ["/bin/bash", "-c"]
     working_dir = path.module
   }
  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
       echo "Deleting k8s cluster. It will take several minutes."
       ../../scripts/delete-cluster.sh
     EOT
     interpreter = ["/bin/bash", "-c"]
     working_dir = path.module
   }
}
