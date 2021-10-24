terraform {
    required_providers {
        aws= {
            source ="hashicorp/aws"
            version= "~>3.5.0"
        }

        docker = {
            source  = "kreuzwerker/docker"
            version = "~> 2.13.0"
       }
    }
}

provider "aws" {
    region = "eu-west-1"
}

provider "docker" {
  version = "~> 2.7"
  host    = "npipe:////.//pipe//docker_engine"
}

resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = false
}

resource "docker_container" "nginx" {
  image = docker_image.nginx.latest
  name  = "GreenCoinFront"
  ports {
    internal = 80
    external = 8000
  }
}

resource "aws_budgets_budget" "like-and-subscribe" {
    name                = "monthly-budget"
    budget_type         = "COST"
    limit_amount        = "25.0"
    limit_unit          = "USD"
    time_unit           = "MONTHLY"
    time_period_start   = "2021-10-24_00:01"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  user_data = <<-EOL
  #!/bin/bash -xe

  apt update
  apt install openjdk-8-jdk --yes
  wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
  echo "deb https://pkg.jenkins.io/debian binary/" >> /etc/apt/sources.list
  apt update
  apt install -y jenkins
  systemctl status jenkins
  find /usr/lib/jvm/java-1.8* | head -n 3  
  EOL

  tags = {
    Name = "GreenCoin"
  }
}

