provider "aws" {
  region = "us-east-1"
}

#Create VPC
resource "aws_vpc" "simple_vpc" {
  cidr_block           = var.VPC_cidr
  enable_dns_support   = "true" 
  enable_dns_hostnames = "true" 
  instance_tenancy     = "default"

tags = {
    Name = var.vpc_tag_name
  }
}

# Public Subnet 1
resource "aws_subnet" "sub1" {
  vpc_id                  = aws_vpc.simple_vpc.id
  cidr_block              = var.sub1_cidr
  map_public_ip_on_launch = "true" 
  availability_zone       = var.az1

}

#Public Subnet 2
resource "aws_subnet" "sub2" {
  vpc_id                  = aws_vpc.simple_vpc.id
  cidr_block              = var.sub2_cidr
  map_public_ip_on_launch = "true" 
  availability_zone       = var.az2

}

#Private Subnet 1
resource "aws_subnet" "sub3" {
  vpc_id                  = aws_vpc.simple_vpc.id
  cidr_block              = var.sub3_cidr
  map_public_ip_on_launch = "false" //it makes private subnet
  availability_zone       = var.az1

}

#Private Subnet  2

resource "aws_subnet" "sub4" {
  vpc_id                  = aws_vpc.simple_vpc.id
  cidr_block              = var.sub4_cidr
  map_public_ip_on_launch = "false" //it makes private subnet
  availability_zone       = var.az2

}

#Internet Gateway
resource "aws_internet_gateway" "internet_gw" {
  vpc_id = aws_vpc.simple_vpc.id

  tags = {
    Name = var.igw_tag
  }
}

#Route Table 
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.simple_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gw.id
  }
  tags = {
    Name = "public_rt"
  }
}

#Associate route table to to the public subnets
resource "aws_route_table_association" "public_subnet_1" {
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_subnet_2" {
  subnet_id      = aws_subnet.sub2.id
  route_table_id = aws_route_table.public_rt.id
}

#Provision elastic IP for each private subnet
resource "aws_eip" "nat1" {
  vpc      = true
}

resource "aws_eip" "nat2" {
  vpc      = true
}

#Create NAT gateway for the private subnets 
resource "aws_nat_gateway" "nat_gateway1" {
  allocation_id = aws_eip.nat1.id
  subnet_id     = aws_subnet.sub1.id

  tags = {
    Name = "gw_NAT1"
  }
}

resource "aws_nat_gateway" "nat_gateway2" {
  allocation_id = aws_eip.nat2.id
  subnet_id     = aws_subnet.sub2.id

  tags = {
    Name = "gw NAT2"
  }
}

#Create route tables for private subnets 
  resource "aws_route_table" "nat_rt1" {
  vpc_id = aws_vpc.simple_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway1.id
  }

  tags = {
    Name = "nat_rt1"
  }
}

resource "aws_route_table" "nat_rt2" {
  vpc_id = aws_vpc.simple_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway2.id
  }

  tags = {
    Name = "nat_rt2"
  }
}

#Associate route tables with subnets 
resource "aws_route_table_association" "nat_gw1" {
  subnet_id      = aws_subnet.sub3.id
  route_table_id = aws_route_table.nat_rt1.id
}

resource "aws_route_table_association" "nat_gw2" {
  subnet_id      = aws_subnet.sub4.id
  route_table_id = aws_route_table.nat_rt2.id
}





#EC2 SG

resource "aws_security_group" "ec2_allow_rule" {


  dynamic "ingress" {
    for_each = toset(var.ports)
    content {
        from_port   = ingress.value
        to_port     = ingress.value
        protocol    = "tcp"
        #cidr_blocks = ["0.0.0.0/0"]
        security_groups = [aws_security_group.lb.id]
  }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    #cidr_blocks = ["0.0.0.0/0"]
    security_groups = [aws_security_group.lb.id]
  }
  vpc_id = aws_vpc.simple_vpc.id
  tags = {
    Name = "allow HTTP"
  }
}


#EC2 
resource "aws_instance" "red_hat_ec2" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.sub2.id
  vpc_security_group_ids = ["${aws_security_group.ec2_allow_rule.id}"]
  key_name               = aws_key_pair.newkey.id
  tags = {
    Name = var.ec2_tag
  }

}

#Send public key to the instance 
resource "aws_key_pair" "newkey" {
  key_name   = var.key_name
  public_key = var.public_key
}

output "ec2_global_ips" {
  value = "${aws_instance.red_hat_ec2.*.public_ip}"
}