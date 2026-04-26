#Complete Project in one place.

# -------------------------
# 1. Provider (AWS connection)
# -------------------------
provider "aws" {
  region = "ap-south-1"
}

# -------------------------
# 2. Variable (map of servers)
# -------------------------
variable "servers" {
  default = {
    web = {
      instance_type = "t2.micro"
      name          = "WebServer"
    }
    app = {
      instance_type = "t2.small"
      name          = "AppServer"
    }
    db = {
      instance_type = "t2.medium"
      name          = "DBServer"
    }
  }
}

# -------------------------
# 3. AMI variable
# -------------------------
variable "ami" {
  default = "ami-0f58b397bc5c1f2e8"
}

# -------------------------
# 4. VPC
# -------------------------
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# -------------------------
# 5. Subnet
# -------------------------
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
}

# -------------------------
# 6. Internet Gateway
# -------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

# -------------------------
# 7. Route Table
# -------------------------
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# -------------------------
# 8. Route Table Association
# -------------------------
resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.rt.id
}

# -------------------------
# 9. Security Group
# -------------------------
resource "aws_security_group" "sg" {
  name   = "allow_ssh_http"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# -------------------------
# 10. EC2 Instances (for_each)
# -------------------------
resource "aws_instance" "servers" {
  for_each = var.servers

  ami           = var.ami
  instance_type = each.value.instance_type

  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.sg.id]

  tags = {
    Name = each.value.name
    Role = each.key
  }
}

# -------------------------
# 11. Output
# -------------------------
output "server_ips" {
  value = {
    for k, v in aws_instance.servers : k => v.public_ip
  }
}


# Variable for the above project
variable "region" {
  default = "ap-south-1"
}
variable "vpc_cidr" {
  default = "10.0.0.0/16"
}
variable "subnet_cidr" {
  default = "10.0.1.0/24"
}
variable "ami" {
  default = "ami-0f58b397bc5c1f2e8"
}
variable "instances" {
  default = {
    dev  = "t2.micro"
    prod = "t2.micro"
  }


