resource "aws_vpc" "my-vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "new-vpc"
  }
}
resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.my-vpc.id
  cidr_block              = var.subnet1_cidr
  availability_zone       = var.availability_zone1
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-1"
  }
}
resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.my-vpc.id
  cidr_block              = var.subnet2_cidr
  availability_zone       = var.availability_zone2
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-2"
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my-vpc.id
  tags = {
    Name = "my-igw"
  }
}
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.my-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "my-route-table"
  }
}
resource "aws_route_table_association" "rt-as-sub-1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.rt.id
}
resource "aws_route_table_association" "rt-as-sub-2" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.rt.id
}
resource "aws_security_group" "my-sg" {
  name        = "web-sg"
  description = "allow http and ssh"
  vpc_id      = aws_vpc.my-vpc.id
  ingress {
    description = "http from vpc"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "ssh from vpc"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks        = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "web-sg"
  }
}
resource "aws_instance" "myinstance-1" {
  ami                = var.instance_ami
  instance_type      = var.instance_type
  subnet_id          = aws_subnet.subnet1.id
  vpc_security_group_ids = [aws_security_group.my-sg.id]
  user_data = file("${path.module}/userdata.sh")
  tags = {
    Name = "web-server-1"
  }
}
resource "aws_instance" "myinstance-2" {
  ami                = var.instance_ami
  instance_type      = var.instance_type
  subnet_id          = aws_subnet.subnet2.id
  vpc_security_group_ids = [aws_security_group.my-sg.id]
  user_data = file("${path.module}/userdata.sh")
  tags = {
    Name = "web-server-2"
  }
}
resource "aws_lb" "my-lb" {
  name               = "myalb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.my-sg.id]
  subnets            = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
  tags = {
    Name = "web"
  }
}
resource "aws_lb_target_group" "tg-group" {
  name     = "myTG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my-vpc.id
  health_check {
    path = "/"
    port = "traffic-port"
  }
}
resource "aws_lb_target_group_attachment" "attach1" {
  target_group_arn = aws_lb_target_group.tg-group.arn
  target_id        = aws_instance.myinstance-1.id
  port             = 80
}
resource "aws_lb_target_group_attachment" "attach2" {
  target_group_arn = aws_lb_target_group.tg-group.arn
  target_id        = aws_instance.myinstance-2.id
  port             = 80
}
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.my-lb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.tg-group.arn
    type             = "forward"
  }
}
