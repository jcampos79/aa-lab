network:
  version: 2
  ethernets:
    en_iface:
      match:
        name: "en*"
      addresses:
        - ${ip_address}/${prefix}
      gateway4: ${gateway}
      nameservers:
        addresses:
          - ${dns}
