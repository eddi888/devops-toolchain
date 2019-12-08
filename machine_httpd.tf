
resource "aws_instance" "httpd" {
  ami           = data.aws_ami.ubuntu.id
  availability_zone = var.availability_zone
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.subnet1.id
  associate_public_ip_address = true
  ebs_optimized = true
  key_name = "admin"
  vpc_security_group_ids = [aws_security_group.all_out.id,
                            aws_security_group.ssh_in.id,
							aws_security_group.public_http_in.id,
							aws_security_group.public_https_in.id,
                            aws_security_group.ping_in.id]
  tags = {
    Name      = "HTTPD (${var.public_domain_name})"
    Team      = "DevOps Toolchain"
  }
  

  
}

resource "null_resource" "httpd_provisioner_v2" {
  connection {
    type        = "ssh"
    user        = "ubuntu"
	private_key = file(var.private_admin_key_file)
	host        = aws_eip.httpd.public_ip
  }

  provisioner "file" {
    source      = "machine-httpd/"
    destination = "/home/ubuntu/"
  }
  
  provisioner "remote-exec" {
    inline = ["sudo chmod +x /home/ubuntu/provisioner.sh",
			  "sudo /home/ubuntu/provisioner.sh ${var.public_domain_name} ${var.email}"]
  }
  
  depends_on = [aws_instance.httpd,
	            aws_route53_record.nexusHttpProxy,
	            aws_route53_record.jenkinsHttpProxy,
	            aws_eip.httpd]
}

