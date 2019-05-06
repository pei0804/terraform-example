provider "aws" {
  region = "ap-northeast-1"
  profile = "default"
}

// 上書き可能
// var.example_instance_type
variable "example_instance_type" {
  default = "t3.micro"
}

variable "env" {}

// 定数
locals {
  example_instance_type = "t3.micro"
}

// data.aws.ami.recent_amazon_linux_2.image_idでアクセス出来る
data "aws_ami" "recent_amazon_linux_2" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name = "name"
    values = ["amzn2-ami-hvm-2.0.????????-x86_64-gp2"]
  }

  filter {
    name = "state"
    values = ["available"]
  }
}

resource "aws_security_group" "example_ec2" {
  name = "example-ec2"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "example" {
  ami = "ami-0f9ae750e8274075b"
  instance_type = var.env == "prod" ? "m5.large" : "t3.micro"
  vpc_security_group_ids = [aws_security_group.example_ec2.id]

  tags = {
    Name = "example"
  }

//  user_data     = file("./user_data.sh")
  user_data = <<EOF
    #!/bin/bash
    yum install -y httpd
    systemctl start httpd.service
EOF
}

// 終了時にawsinstance exampleのidを取得出来る
output "example_instance_id" {
  value = aws_instance.example.id
}
