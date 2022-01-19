output "network_details" {
      value = data.terraform_remote_state.network
}

output "webserver_sg_id" {
      value = aws_security_group.webserver.id
}


