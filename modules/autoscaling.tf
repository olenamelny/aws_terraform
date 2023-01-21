

#Launch Configuration
resource "aws_launch_configuration" "configuration" {
  image_id        = var.ami
  instance_type   = var.instance_type
  user_data       = <<-EOF
  #!/bin/bash
  echo "*** Installing apache2"
  sudo apt update -y
  sudo apt install apache2 -y
  echo "*** Completed Installing apache2"
  EOF

  security_groups = [aws_security_group.ec2_allow_rule.id]

  lifecycle {
    create_before_destroy = true
  }
}

#Auto scaling group
resource "aws_autoscaling_group" "asg" {
  min_size             = 2
  max_size             = 6
  desired_capacity     = 2
  launch_configuration = aws_launch_configuration.configuration.name
  vpc_zone_identifier  = [aws_subnet.sub3.id, aws_subnet.sub4.id]
}

#Create Application load balancer
resource "aws_lb" "load_balancer" {
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb.id]
  subnets            = [aws_subnet.sub3.id, aws_subnet.sub4.id]
}

#Listener for the load balacer 
resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.group.arn
  }
}

resource "aws_lb_target_group" "group" {
   port     = 80
   protocol = "HTTP"
   vpc_id   = aws_vpc.simple_vpc.id
 }

resource "aws_autoscaling_attachment" "as_attachment" {
  autoscaling_group_name = aws_autoscaling_group.asg.id
  lb_target_group_arn   = aws_lb_target_group.group.arn
}

#Load balancer security group
resource "aws_security_group" "lb" {
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = aws_vpc.simple_vpc.id
}