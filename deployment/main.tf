terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc4"
    }
  }
}

provider "proxmox" {
  pm_api_url = "${var.pm_api_url}"
  pm_api_token_id = "${var.pm_api_token_id}"
  pm_api_token_secret = "${var.pm_api_token_secret}"
}

resource "proxmox_vm_qemu" "new_vm" {
  vmid        = "2001"
  name        = "eggplant"
  target_node = "pve3"
  clone       = "eggplant-template"

  agent = 1

  memory     = 4096
  cores      = 2
  os_type    = "cloud-init"
  ipconfig0  = "ip=192.168.10.220/24,gw=192.168.10.1"
  nameserver = "1.1.1.1"

  scsihw  = "virtio-scsi-pci"
  hotplug = "network,disk,usb"

  disks {
    ide {
      ide3 {
        cloudinit {
          storage = "local-lvm"
        }
      }
    }
    scsi {
      scsi0 {
        disk {
          size    = 32
          cache   = "writeback"
          storage = "MIDBOA_SSD500"
         }
      }
    }
  }

  bootdisk = "scsi0"

  serial {
    id   = 0
    type = "socket"
  }

  network {
    model  = "virtio"
    bridge = "vmbr1"
  }

  connection {
    type     = "ssh"
    user     = "${var.ssh_user}"
    password = "${var.ssh_password}"
    host     = self.ssh_host
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install python3.12 python3-pip3 python3-flask",
      "sudo mkdir /opt/app",
      "sudo wget https://github.com/aznaveeck/eggplanter-website/releases/download/v0.1.3/app.py -O /opt/app/",
      "sudo chmod +x /opt/app/app.py",
      "python3 /opt/app/app.py"
    ]
  }

}