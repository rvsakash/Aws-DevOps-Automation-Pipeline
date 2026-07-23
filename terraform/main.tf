terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# 1. Core VPC Setup
resource "aws_vpc" "devops_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name    = "devops-vpc"
    Project = "aws-devops-automation"
  }
}

# 2. Public Subnet 1 (Zone A)
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.devops_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true
  tags = {
    Name    = "devops-public-subnet-1"
    Project = "aws-devops-automation"
  }
}

# 3. Public Subnet 2 (Zone B)
resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.devops_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true
  tags = {
    Name    = "devops-public-subnet-2"
    Project = "aws-devops-automation"
  }
}

# 4. Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.devops_vpc.id
  tags = {
    Name    = "devops-igw"
    Project = "aws-devops-automation"
  }
}

# 5. Route Table Routing Rules
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.devops_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name    = "devops-public-rt"
    Project = "aws-devops-automation"
  }
}

# 6. Associate Route Table with Both Subnets
resource "aws_route_table_association" "public_assoc_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_assoc_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

# 7. Security Group 
resource "aws_security_group" "web_sg" {
  name   = "web-server-sg"
  vpc_id = aws_vpc.devops_vpc.id

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

  ingress {
    from_port   = 9100 
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9090 
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000 
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "devops-web-sg"
    Project = "aws-devops-automation"
  }
}

# 8. Web Server Instances Allocation
resource "aws_instance" "web_servers" {
  count                       = 2 
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = count.index == 0 ? aws_subnet.public_subnet_1.id : aws_subnet.public_subnet_2.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

  # CRITICAL INTERVIEWER HIGHLIGHT: Stops Terraform from deleting your instances 
  # when you stop/start them manually.
  lifecycle {
    ignore_changes = [
      instance_state,
    ]
  }

  tags = {
    Name    = "devops-webserver-${count.index + 1}"
    Project = "aws-devops-automation"
    Role    = "webserver"
  }
}

# 9. Application Load Balancer Setup
resource "aws_lb" "app_alb" {
  name               = "devops-architecture-alb-v2"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_sg.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]

  tags = {
    Project = "aws-devops-automation"
  }
}

# 10. Blue Target Group
resource "aws_lb_target_group" "blue_tg" {
  name     = "tg-blue-environment-v2"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.devops_vpc.id

  health_check {
    path                = "/"
    port                = "80"
    protocol            = "HTTP"
    interval            = 10 
    timeout             = 4
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# 11. Green Target Group
resource "aws_lb_target_group" "green_tg" {
  name     = "tg-green-environment-v2"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.devops_vpc.id

  health_check {
    path                = "/"
    port                = "80"
    protocol            = "HTTP"
    interval            = 10
    timeout             = 4
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# 12. ALB Listener Routing Configuration
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue_tg.arn
  }
}

# 13. Dynamic Target Attachments for 2 EC2 Web Servers
resource "aws_lb_target_group_attachment" "web_attach" {
  count            = 2 
  target_group_arn = aws_lb_target_group.blue_tg.arn
  target_id        = aws_instance.web_servers[count.index].id
  port             = 80
}
