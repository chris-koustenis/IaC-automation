variable "region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-west-1"
}

variable "key_name" {
  description = "Existing AWS EC2 key pair name for SSH"
  type        = string
}
