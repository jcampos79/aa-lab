variable "libvirt_uri" {
  description = "Libvirt connection URI. Use 'qemu:///system' for local KVM or 'qemu+sshcmd://user@host/system' for remote (respects ~/.ssh/config)."
  type        = string
  default     = "qemu:///system"
}

variable "storage_pool_path" {
  description = "Directory on the KVM host where VM images are stored."
  type        = string
  default     = "/var/lib/libvirt/images/k8s"
}

variable "base_image_url" {
  description = "URL or local path (file:///...) of the Ubuntu 22.04 cloud image (qcow2)."
  type        = string
  default     = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key injected into VMs via cloud-init."
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "ssh_user" {
  type    = string
  default = "ubuntu"
}
# ── Network ───────────────────────────────────────────────────────────────────

variable "network_cidr" {
  description = "CIDR for the libvirt NAT network. Kept identical to the original AWS private subnet so MetalLB/nip.io URLs are unchanged."
  type        = string
  default     = "10.0.1.0/24"
}

variable "dns_server" {
  description = "DNS server for the VMs."
  type        = string
  default     = "8.8.8.8"
}


# ── Disk ──────────────────────────────────────────────────────────────────────

variable "disk_size_bytes" {
  description = "Root disk size in bytes for each VM (default 40 GiB)."
  type        = number
  default     = 42949672960 # 40 GiB
}

variable "worker_count" {
  description = "Number of worker nodes."
  type        = number
  default     = 2
}

variable "worker_vcpus" {
  description = "vCPUs for each worker node."
  type        = number
  default     = 2
}

variable "worker_memory_mb" {
  description = "RAM in MiB for each worker node."
  type        = number
  default     = 4096
}
