module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "portfolio-server-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-central-1a", "eu-central-1b"]
  private_subnets = ["10.0.1.0/24"]
  public_subnets  = ["10.0.101.0/24"]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

data "aws_ami" "ubuntu_2004" {
  owners      = ["099720109477"] // Canonical
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

// Replace the ec2 module with a native aws_instance to avoid SSM
resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu_2004.id
  instance_type          = "t2.micro"
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [module.vpc.default_security_group_id]
  associate_public_ip_address = true
  key_name               = var.key_name

  user_data = <<-EOT
              #!/usr/bin/env bash
              set -euxo pipefail
              apt-get update -y
              apt-get install -y nginx
              systemctl enable nginx
              systemctl restart nginx
              echo "<h1>Portfolio Server</h1><p>NGINX is up!</p>" > /var/www/html/index.html
              EOT

  tags = {
    Name        = "portfolio-server-instance"
    Terraform   = "true"
    Environment = "dev"
  }
}

module "web_server_sg" {
  source = "terraform-aws-modules/security-group/aws//modules/http-80"

  name        = "web-server"
  description = "Security group for web-server with HTTP ports open within VPC"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group" "ssh" {
  name        = "ssh-access"
  description = "Allow SSH from anywhere (adjust as needed)"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "ssh-access"
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_security_group_rule" "http_attach" {
  type              = "ingress"
  security_group_id = module.vpc.default_security_group_id
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow HTTP to default SG"
}

resource "aws_security_group_rule" "ssh_attach" {
  type              = "ingress"
  security_group_id = module.vpc.default_security_group_id
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow SSH to default SG"
}
