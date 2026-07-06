data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_instance" "blog" {
  ami           = data.aws_ami.app_ami.id
  instance_type = var.instance_type

  vpc_security_group_ids = [module.blog_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y nginx
    systemctl enable nginx
    systemctl start nginx
    EOF

  tags = {
    Name = "HelloWorld"
  }
}

module "blog_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "6.0.0"
  name    = "blog_new"

  vpc_id = data.aws_vpc.default.id

  ingress_rules = {
    http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
      description = "HTTP"
    }
    https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
      description = "HTTPS"
    }
  }

  egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
}

