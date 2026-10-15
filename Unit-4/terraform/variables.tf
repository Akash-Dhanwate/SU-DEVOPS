variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "student-platform"
}

variable "vpc_cidr" {
  type    = string
  default = "10.1.0.0/16"
}

variable "public_subnet_cidr" {
  type    = string
  default = "10.1.1.0/24"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "root_volume_size" {
  type    = number
  default = 20
}

variable "app_port" {
  type    = number
  default = 8080
}

variable "key_name" {
  type    = string
  default = "student-aws-key"
}

variable "public_key_path" {
  type    = string
  default = "~/.ssh/student-aws-key.pub"
}

variable "private_key_path" {
  type    = string
  default = "~/.ssh/student-aws-key"
}

variable "ssh_allowed_cidr" {
  description = "CIDR allowed to SSH. Set to <your-ip>/32 for security."
  type        = string
  default     = "0.0.0.0/0"
}
