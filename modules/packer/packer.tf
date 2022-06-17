resource "null_resource" "wp-packer" {
  provisioner "local-exec" {
    command = <<EOF
packer build \
 -var 'priv-subnet=${var.subnet}' \
 -var 'project=${var.project}'\
 -var 'zone=${var.zone}'\
 -var 'image-name=${var.image-name}' \
 -var 'source-image=${var.source-image}' \
 -var 'bastion-ip=${var.bastion-ip}' \
 -var 'ssh-private-key-path=${var.ssh-private-key-path}' \
 -var 'username=${var.ssh-username}' \
 -var 'machine-type=${var.packer-machine-type}' \
 -var 'playbook=${var.playbook}' \
 -var 'ansible-extra-vars=${var.ansible-extra-vars}' \
 packer/packer.pkr.hcl
sleep 25
EOF
  }
}