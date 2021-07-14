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

#Variables for server-port(8080)

variable "server_port" {
    description = "The port the server will use for HTTP requests"
    type = number
    default = 8080
}

#Example of data source:
data "aws_vpc" "default" {
    default = true
}

data "aws_subnet_ids" "default" {
    vpc_id = data.aws_vpc.default.id
}

#Example of launch configuration:
resource "aws_launch_configuration" "terraform-example-launch" {

    image_id = "ami-0c55b159cbfafe1f0"
    instance_type = "t2.micro"
    security_groups = [aws_security_group.terraform-sec-instance.id]
    user_data = <<-EOF
        #!/bin/bash
        echo "Hello, World" > index.html
        nohup busybox httpd -f -p
        ${var.server_port} &
        EOF
    lifecycle {
        create_before_destroy = true
    }
}

#Example of Auto Scaling group:
resource "aws_autoscaling_group" "autoscale-example" {

    launch_configuration = aws_launch_configuration.terraform-example-launch.name
    min_size = 2
    max_size = 10
    vpc_zone_identifier = data.aws_subnet_ids.default.ids #Argument for subnet_ids 
    tag {
        key = "Name"
        value = "terraform-asgexample"
        propagate_at_launch = true
    }

}





