# Local KVM (default).
# For a remote KVM host (native SSH, respects ~/.ssh/config):
#   libvirt_uri = "qemu+sshcmd://ubuntu@192.168.1.10/system"
libvirt_uri = "qemu+ssh://jcampos@oem.saga.org/system"

# Where disk images are stored on the KVM host
storage_pool_path = "/storage/images/aa-lab"

# Ubuntu 24.04 cloud image.
base_image_url = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"

ssh_public_key_path = "~/.ssh/k8-devops-kvm.pub"
ssh_user            = "ubuntu"

# Network — same CIDR as original project so MetalLB/nip.io URLs are unchanged
network_cidr = "10.0.1.0/24"
dns_server   = "8.8.8.8"

# Disk: 40 GiB per node
disk_size_bytes = 42949672960

# Workers
worker_count     = 2
worker_vcpus     = 4
worker_memory_mb = 8192
