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

  memory  = 4096
  cores   = 2
  os_type = "cloud-init"

  scsihw                  = "virtio-scsi-pci"
  hotplug                 = "network,disk,usb"

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
                    size            = 32
                    cache           = "writeback"
                    storage         = "XXLBOA_HDD4TB"
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
}