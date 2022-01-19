#----------------------------------------------------------
# My Terraform
#
# Remote  Terraform State on S3
#
# Made by Nagiev Natig
#----------------------------------------------------------


provider "aws" {

  region = "eu-central-1"

}

terraform {

  backend "s3" {

    bucket = "my-terraform-udemy"
    key    = "dev/network/terraform.tfstate"
    region = "eu-central-1"
  }


}

data "aws_availability_zones" "available" {}



#------------------------------------------------------------

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "${var.env}-vpc"
  }

}

resource "aws_internet_gateway" "main" {

  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.env}-igw"
  }
}

resource "aws_subnet" "public_subnets" {
  count                   = length(var.publick_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  availability_zones      = data.aws_availability_zones.available.name[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.env}-public-${count.index + 1}"

  }
}

resource "aws_route_table" "public_subnets" {
    

} 

