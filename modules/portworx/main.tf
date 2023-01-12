resource "null_resource" "setup" {
  provisioner "local-exec" {
     command = <<-EOT
       echo "Setting up Portworx cluster. It will take several minutes."
       ../../scripts/install-portworx.sh
     EOT
     interpreter = ["/bin/bash", "-c"]
     working_dir = path.module
   }
  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
       echo "Deleting Portworx cluster. It will take several minutes."
       ../../scripts/remove-portworx.sh
     EOT
     interpreter = ["/bin/bash", "-c"]
     working_dir = path.module
   }
}
