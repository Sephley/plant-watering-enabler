# Packer Template to create an Ubuntu Server (noble) on Proxmox

# Resource Definition for the VM Template
source "proxmox-iso" "ubuntu-noble" {
 
    # Proxmox Connection Settings
    proxmox_url = "${var.pm_api_url}"
    username = "${var.pm_api_token_id}"
    token = "${var.pm_api_token_secret}"
    insecure_skip_tls_verify = true
    
    # VM General Settings
    node = "pve3"
    vm_id = "9010"
    vm_name = "eggplant"
    template_name = "eggplant-template"
    template_description = "Ubuntu Noble template for eggplanting"

    # Download ISO (source:https://releases.ubuntu.com/22.04/ubuntu-22.04.3-live-server-amd64.iso)
    iso_file = "local:iso/ubuntu-22.04.3-live-server-amd64.iso"
    iso_checksum = "a4acfda10b18da50e2ec50ccaf860d7f20b389df8765611142305c0e911d16fd"
    iso_storage_pool = "local"
    unmount_iso = true

    # VM System Settings
    cores = "2"
    memory = "4096"
    qemu_agent = true

    # VM Hard Disk Settings
    scsi_controller = "virtio-scsi-pci"

    disks {
        disk_size = "25G"
        format = "raw"
        storage_pool = "local-lvm"
        type = "virtio"
    }

    # VM Network Settings
    network_adapters {
        model = "virtio"
        bridge = "vmbr1"
    } 

    # VM Cloud-Init Settings
    cloud_init = true
    cloud_init_storage_pool = "local-lvm"

    # PACKER Boot Commands
    boot_command = [
        "<esc><wait>",
        "e<wait>",
        "<down><down><down><end>",
        "<bs><bs><bs><bs><wait>",
        "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait>",
        "<f10><wait>"
    ]
    boot = "c"
    boot_wait = "5s"

    # PACKER Autoinstall Settings
    http_directory = "http" 

    # Bind Port
    http_port_min = 8802
    http_port_max = 8802

    # SSH credentials - these are not used in prod
    ssh_username = "root"
    ssh_password = "packer"

    # Raise the timeout in case installation takes longer
    ssh_timeout = "20m"
}

# Build Definition to create the VM Template
build {

    name = "ubuntu-noble"
    sources = ["source.proxmox-iso.ubuntu-noble"]

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #1
    provisioner "shell" {
        inline = [
            "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
            "sudo rm /etc/ssh/ssh_host_*",
            "sudo truncate -s 0 /etc/machine-id",
            "sudo apt -y autoremove --purge",
            "sudo apt -y clean",
            "sudo apt -y autoclean",
            "sudo cloud-init clean",
            "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
            "sudo rm -f /etc/netplan/00-installer-config.yaml",
            "sudo sync"
        ]
    }

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #2
    provisioner "file" {
        source = "files/99-pve.cfg"
        destination = "/tmp/99-pve.cfg"
    }

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #3
    provisioner "shell" {
        inline = [ "sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg" ]
    }

    # Add additional provisioning scripts here
    # ...
}
