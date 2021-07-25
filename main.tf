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
   ingress {
       
       from_port = 22 
       to_port = 22
       protocol = "tcp"
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
    name = "test-for-web"
    image_id = "ami-05f7491af5eef733a"
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
    target_group_arns = [aws_lb_target_group.asg.arn]
    health_check_type = "ELB"
    tag {
        key = "Name"
        value = "terraform-asgexample"
        propagate_at_launch = true
    }

}

#Create an ALB load-balancer for our app servers:

resource "aws_lb" "aws_example" {

    name               = "terrafor-alb-example"
    load_balancer_type = "application"
    subnets            = data.aws_subnet_ids.default.ids
    security_groups    = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "http" {

    load_balancer_arn = aws_lb.aws_example.arn
    port              = 80
    protocol          = "HTTP"

#By default return empty string with 404 code

    default_action {

        type = "fixed-response"

        fixed_response {

            content_type = "text/plain"
            message_body = "404: page not found"
            status_code  = 404

        }
    }
}
#Example of a security_group for our ALB:
resource "aws_security_group" "alb" {

    name = "terraform-example-alb"
    ingress {
        from_port = 80
        to_port   = 80
        protocol  = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port   = 0 
        protocol  = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

}

#Example of a target_group for out ASG:

resource "aws_lb_target_group" "asg" {
    name = "terraform-asg-example01"
    port = var.server_port
    protocol = "HTTP"
    vpc_id = data.aws_vpc.default.id
    health_check {
        path = "/"
        protocol = "HTTP"
        matcher = "200"
        interval = 15
        timeout = 3
        healthy_threshold = 2
        unhealthy_threshold = 2

    }
}

#Example of a create aws-lb-listener-rule:

resource "aws_lb_listener_rule" "asg" {

    listener_arn = aws_lb_listener.http.arn
    priority = 100
    condition {
        path_pattern {
            values = ["*"]
        }
    }
    action {
        type = "forward"
        target_group_arn = aws_lb_target_group.asg.arn
         
    }
}

output "alb_dns_name" {

    value       = aws_lb.aws_example.dns_name
    description = "The domain name of the load balancer"

}

#Test commit from VS code
