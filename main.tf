provider "aws" {

    region = "eu-central-1"
}


resource "aws_security_group" "terraform-sec-instance" {

    name        = "terraform-sec-instance"

    ingress {

        from_port = 8080
        to_port   = 8080
        protocol  = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

    
resource "aws_instance" "terraform-example" {
    ami       = "ami-00f22f6155d6d92c5"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.terraform-sec-instance.id]
    user_data     = <<-EOF
                #!/bin/bash
                echo "Hello, World" > index.html
                nohup busybox httpd -f -p 8080 &
                EOF
    tags = {
        Name = "terraform-example"
    }
}
output "public_ip" {
    value = aws_instance.terraform-example.public_ip
    description = "The public IP address of the web server"
}
output "source_instance_id" {
value = aws_instance.terraform-example.id
description = "The instance_id of the web server"
}    

