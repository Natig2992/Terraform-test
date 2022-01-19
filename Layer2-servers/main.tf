provider "aws" {
  region = "eu-central-1"
}

terraform {

    backend "s3" {

        bucket = "my-terraform-udemy"
        key = "dev/servers/terraform.tfstate"
        region = "eu-central-1"
    }


}




data "terraform_remote_state" "network" {
  backend = "s3"
  config = {

    bucket = "my-terraform-udemy"
    key    = "dev/network/terraform.tfstate"
    region = "eu-central-1"

  }

}

#----------------------------------------------------

resource "aws_security_group" "webserver" {

  name   = "Webserver Security Group"
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id

  ingress {
    from_port  = 80
    to_port    = 80
    protocol   = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

 ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [data.terraform_remote_state.network.outputs.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "webserver-server-sg"
    Owner = "Nagiev Natig"

  }
}


