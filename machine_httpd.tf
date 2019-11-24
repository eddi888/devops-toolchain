
resource "aws_instance" "httpd" {
  ami           = data.aws_ami.ubuntu.id
  availability_zone = var.availability_zone
  instance_type = "t3.nano"
  subnet_id     = aws_subnet.subnet1.id
  associate_public_ip_address = true
  key_name = "admin"
  vpc_security_group_ids = [aws_security_group.all_out.id,
                            aws_security_group.ssh_in.id,
							aws_security_group.http_in.id,
							aws_security_group.https_in.id,
                            aws_security_group.ping_in.id]
  tags = {
    Name      = "HTTPD"
    Team      = "DevOps Toolchain"
  }
  
  connection {
    type        = "ssh"
    user        = "ubuntu"
	private_key = file(var.private_admin_key_file)
	host        = self.public_ip
  }

  provisioner "file" {
    source      = "scripts/httpd-provisioner.py"
    destination = "/home/ubuntu/httpd-provisioner.py"
  }
  
  provisioner "remote-exec" {
    inline = ["sudo apt-get update",
	          "sudo apt-get upgrade -y",
			  "sudo apt-get install -y python3",
			  "sudo python3 /home/ubuntu/httpd-provisioner.py"]
  }
}
