#cloud-config
hostname: ${hostname}
manage_etc_hosts: true

users:
  - name: ubuntu
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    lock_passwd: true
    ssh_authorized_keys:
      - ${ssh_pubkey}

ssh_pwauth: false

# Grow root partition to fill the disk
growpart:
  mode: auto
  devices: ["/"]

resize_rootfs: true

package_update: true
package_upgrade: true
packages:
  - qemu-guest-agent
  - curl
  - apt-transport-https
  - ca-certificates
  - gnupg

runcmd:
  - systemctl enable --now qemu-guest-agent
