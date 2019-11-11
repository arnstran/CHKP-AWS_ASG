variable "public_key_path" {
  description = <<DESCRIPTION
Path to the SSH public key to be used for authentication.
Ensure this keypair is added to your local SSH agent so provisioners can
connect.
Example: ~/.ssh/terraform.pub
DESCRIPTION
}

variable "aws_region" {
  description = "AWS region to launch servers."
}
variable "key_name" {
  description = "Desired name of AWS key pair"
}
variable "aws_vpc_cidr" {
}
variable "my_user_data" {
}
variable "ubuntu_user_data" {
}
variable "externaldnshost" {
}
variable "cg_size" {
}
variable "ws_size" {
}
variable "r53zone" {
}
variable "SICKey" {
}
variable "AllowUploadDownload" {
}
variable "pwd_hash" {
}
variable "management_server_name" {
  description = "The management server used in CME (autoprov_cfg)"
}
variable "template_name" {
  description = "The template used in CME (autoprov_cfg)"
}

data "aws_availability_zones" "azs" {}

# Check Point R80 BYOL
data "aws_ami" "chkp_ami" {
  most_recent      = true
  filter {
    name   = "name"
    values = ["Check Point CloudGuard IaaS GW BYOL R80.30-*"]
  }
  owners = ["679593333241"]
}

# Ubuntu Image
data "aws_ami" "ubuntu_ami" {
  most_recent      = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }
}