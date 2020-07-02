# Azure Virtual Machine
This repository contains a sample Terraform configuration to create an Azure Virtual Machine resource. This example assumes that the purpose of the virtual machine is to prepare a functional Terraform server with an Ubuntu operating system. However, the ultimate intent is to change the properties of this generic item to fit more complex scenarios.

## About this example

* Clone this repository to your local machine.
* Modify the final properties of the target environment by making changes in the contents of `terraform.tfvars`. Making changes there supercedes the default changes in `variables.tf`.
* Make it your own

### Azure Security Credentials

To use this configuration, you require appropriate identity credentials to access your Azure environment. More specifically, the following:

```
ARM_SUBSCRIPTION_ID
ARM_CLIENT_SECRET
ARM_TENANT_ID
ARM_CLIENT_ID
```
These should be expressed as environment variables in your local machine and the variables must be available at the time of a Terraform Apply run.

### SSH connectivity

Additionally, we assume that remote connectivity to the virtual machine is allowed. In this example, we make an assumption of a local, hidden `ssh` directory which holds a SSH public key.

```
  admin_ssh_key {
    username   = "tfadmin"
    public_key = file("./.ssh/id_rsa.pub")
  }
```

When you are testing, we recommend the following sequence in your working directory, on your local machine:

```
mkdir .ssh
ssh-keygen -f .ssh/id_rsa
```

The `ssh-keygen` command produces your private and public keys: `id_rsa` and `id_rsa.pub`. You use those to connect to your virtual machine. For instance, assume that your new virtual machine is publically available at 40.86.209.90, then you connect in this manner:

```
ssh -i .ssh/id_rsa tfadmin@40.86.209.90
```

### `gitignore` Files

When storing this configuration, ignore anything to do with Terraform state files, the Terraform provider files, and anything that may expose private data in your local SSH directory.
