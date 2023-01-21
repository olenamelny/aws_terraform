provider "aws" {
  region = var.region 
}

module "vpc" {
    source        = "../modules"
    #VPC
    VPC_cidr      = var.VPC_cidr
    vpc_tag_name  = var.vpc_tag_name
    sub1_cidr     = var.sub1_cidr
    az1           = var.az1
    sub2_cidr     = var.sub2_cidr
    az2           = var.az2
    sub3_cidr     = var.sub3_cidr
    sub4_cidr     = var.sub4_cidr
    igw_tag       = var.igw_tag
    ami           = var.ami
    instance_type = var.instance_type
    ec2_tag       = var.ec2_tag
    ports         = var.ports
    region        = var.region
    public_key    = var.public_key
    key_name      = var.key_name
    
}