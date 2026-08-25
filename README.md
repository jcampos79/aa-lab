# aa-lab

AppArmor lab testing environment automated via Terraform. This repository helps you deploy, provision, and iterate on AppArmor profiles for custom application confinement validation.

## Repository Structure

The project contains the following infrastructure configurations:
* **`main.tf`**: Core Terraform infrastructure manifest.
* **`variables.tf`**: Input configuration schemas for customized deployments.
* **`templates/`**: Provisioning files and application templates.
* **`terraform.tfvars.example`**: Standard pattern template for handling environmental secrets.

---

## Getting Started

### Prerequisites
* [Terraform](https://terraform.io) installed locally.
* A target platform, I am using libvirt (KVM)

### Installation & Deployment

1. **Clone the Repository**
   ```bash
   git clone https://github.com
   cd aa-lab
   ```

2. **Configure Variables**
   Copy the example variables file and adjust it to match your target specifications:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

3. **Initialize & Apply Infrastructure**
   Initialize the required provider plugins and provision the deployment instance:
   ```bash
   terraform init
   terraform apply
   ```

---

## AppArmor Verification Guide

Once the lab instance is active, you can confirm status directly inside the test environment:

1. **Verify Module Activation**
   ```bash
   sudo aa-status
   ```
2. **Review Profiles Under Enforcement**
   Check parsed configurations stored under the standard location `/etc/apparmor.d/`.

---

## Contributing
Feel free to submit an issue or open a pull request to share specialized profiles or add features to this automated lab architecture.

