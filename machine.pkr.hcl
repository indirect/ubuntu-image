packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = "~> 1"
    }
  }
}

variable "ubuntu_version" {
  type        = string
  default     = "noble"
  description = "Ubuntu codename version (i.e. 22.04 is jammy and 24.04 is noble)"
}

source "qemu" "ubuntu" {
  cd_files         = ["./cloud-init/*"]
  cd_label         = "cidata"
  disk_compression = true
  disk_image       = true
  disk_size        = "10G"
  headless         = true
  iso_checksum     = "file:https://cloud-images.ubuntu.com/${var.ubuntu_version}/current/SHA256SUMS"
  iso_url          = "https://cloud-images.ubuntu.com/${var.ubuntu_version}/current/${var.ubuntu_version}-server-cloudimg-amd64.img"
  output_directory = "output-${var.ubuntu_version}"
  shutdown_command = "echo 'packer' | sudo -S shutdown -P now"
  ssh_username     = "ubuntu"
  vm_name          = "ubuntu-${var.ubuntu_version}.img"
  memory           = 2048
  qemuargs         = [
    ["-smp", "2"],
    ["-serial", "mon:stdio"],
  ]
}

build {
  sources = ["source.qemu.ubuntu"]

  provisioner "shell" {
    inline = ["cloud-init status --wait"]
  }
}
