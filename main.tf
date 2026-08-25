terraform {
  required_version = ">= 1.5"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.9.8"
    }
  }
}

# Connect to the local KVM hypervisor.
# For a remote KVM host: "qemu+sshcmd://user@192.168.1.10/system"
provider "libvirt" {
  uri = var.libvirt_uri
}


# ── Local Variables ─────────────────────────────────────────────────────────────
locals {
  workers = {
    for i in range(var.worker_count) :
    "aa-lab-worker-${i + 1}" => {
      ip = cidrhost(var.network_cidr, 11 + i)
    }
  }
}
# ── Storage pool ─────────────────────────────────────────────────────────────

resource "libvirt_pool" "aa-lab" {
  name = "aa-lab-pool"
  type = "dir"

  target = {
    path = var.storage_pool_path
  }

  create = {
    build     = true
    start     = true
    autostart = true
  }
}

# ── Base OS image (downloaded once, used as a backing store) ──────────────────

resource "libvirt_volume" "base_image" {
  name = "ubuntu-24.04-base.qcow2"
  pool = libvirt_pool.aa-lab.name
  target = {
    format = {
      type = "qcow2"
    }
  }

  create = {
    content = {
      url = var.base_image_url
    }
  }
}

resource "libvirt_volume" "worker" {
  count = var.worker_count
  name  = "aa-lab-worker-${count.index + 1}.qcow2"
  pool  = libvirt_pool.aa-lab.name
  target = {
    format = {
      type = "qcow2"
    }
  }
  capacity = var.disk_size_bytes

  backing_store = {
    path   = libvirt_volume.base_image.path
    format = { type = "qcow2" }
  }
}

resource "libvirt_cloudinit_disk" "worker" {
  count = var.worker_count
  name  = "aa-lab-worker-${count.index + 1}-cloudinit"

  meta_data = <<-EOF
    instance-id: aa-lab-worker-${count.index + 1}
    local-hostname: aa-lab-worker-${count.index + 1}
  EOF

  user_data = templatefile("${path.module}/templates/cloud_init.tpl", {
    hostname   = "aa-lab-worker-${count.index + 1}"
    ssh_pubkey = trimspace(file(var.ssh_public_key_path))
  })

  network_config = templatefile("${path.module}/templates/network_config.tpl", {
    ip_address = cidrhost(var.network_cidr, 11 + count.index)
    prefix     = tonumber(split("/", var.network_cidr)[1])
    gateway    = cidrhost(var.network_cidr, 1)
    dns        = var.dns_server
  })
}

# Upload each cloud-init ISO into the pool so the domain can reference it
# as a cdrom volume source.

resource "libvirt_volume" "worker_cloudinit" {
  count = var.worker_count
  name  = "aa-lab-worker-${count.index + 1}-cloudinit.iso"
  pool  = libvirt_pool.aa-lab.name

  create = {
    content = {
      url = libvirt_cloudinit_disk.worker[count.index].path
    }
  }
}

# ── Virtual network (NAT) ─────────────────────────────────────────────────────

resource "libvirt_network" "aa-lab" {
  name      = "aa-lab-net"
  autostart = true

  # v0.9.x: domain is an object, not a string
  domain = {
    name      = "aa-lab.local"
    localOnly = false
  }

  # v0.9.x: forward mode nested in forward object
  forward = {
    mode = "nat"
  }

  # v0.9.x: "ips" (plural), not "ip"
  ips = [{
    address = cidrhost(var.network_cidr, 1)
    prefix  = tonumber(split("/", var.network_cidr)[1])

    dhcp = {
      enabled = false
    }
  }]

}

# ── Worker VMs ────────────────────────────────────────────────────────────────

resource "libvirt_domain" "worker" {
  count       = var.worker_count
  name        = "aa-lab-worker-${count.index + 1}"
  type        = "kvm"
  memory      = var.worker_memory_mb
  memory_unit = "MiB"
  vcpu        = var.worker_vcpus
  autostart   = true
  running     = true

  os = {
    type    = "hvm"
    arch    = "x86_64"
    machine = "q35"
    boot_devices = [{
      dev = "hd"
    }]
  }

  features = {
    acpi = true
  }

  cpu = {
    mode = "host-passthrough"
  }

  devices = {
    disks = [
      {
        device = "cdrom"
        source = {
          volume = {
            pool   = libvirt_volume.worker_cloudinit[count.index].pool
            volume = libvirt_volume.worker_cloudinit[count.index].name
          }
        }
        target = {
          dev = "sda"
          bus = "sata"
        }
      },
      {
        source = {
          volume = {
            pool   = libvirt_volume.worker[count.index].pool
            volume = libvirt_volume.worker[count.index].name
          }
        }
        driver = {
          type = "qcow2"
        }
        target = {
          dev = "vda"
          bus = "virtio"
        }
      }
    ]

    interfaces = [
      {
        type  = "network"
        model = { type = "virtio" }
        source = {
          network = { network = libvirt_network.aa-lab.name }
        }
      }
    ]

    consoles = [{
      type        = "pty"
      target_port = "0"
      target_type = "serial"
    }]

    graphics = [{
      vnc = {
        autoport = "yes"
        listen   = "0.0.0.0"
      }
    }]
  }
}


