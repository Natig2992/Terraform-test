provider "aws" {

    region = "eu-central-1"
}

resource "aws_instance" "nginx" {

 ami            = "ami-0b1deee75235aa4bb"
 instance_type  = "t2.small"
 
 tags = {
   Name = "nginx-test-01"
  }
} 
