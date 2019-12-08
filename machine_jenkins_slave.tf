
resource "aws_instance" "jenkins_slave" {
  ami           = data.aws_ami.ubuntu.id
  availability_zone = var.availability_zone
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.subnet1.id
  associate_public_ip_address = true
  key_name = "admin"
  vpc_security_group_ids = [aws_security_group.tomcat_in.id,
                            aws_security_group.all_out.id,
                            aws_security_group.ssh_in.id,
                            aws_security_group.ping_in.id]
  
  tags = {
    Name      = "Jenkins-Slave (${var.public_domain_name})"
    Team      = "DevOps Toolchain"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
	  private_key = file(var.private_jenkins_slave_key_file)
	  host        = self.public_ip
  }

  provisioner "file" {
    source      = "machine-jenkins-slave/"
    destination = "/home/ubuntu/"
  }
  
  provisioner "remote-exec" {
    inline = ["sudo chmod +x /home/ubuntu/jenkins-slave-provisioner.sh",
			        "sudo /home/ubuntu/jenkins-slave-provisioner.sh ${var.public_domain_name} ${var.email}"]
  }
}

resource "aws_ami_from_instance" "ami_jenkins_slave" {
  name               = "ami_jenkins_slave"
  source_instance_id = aws_instance.jenkins_slave.id
  tags = {
    Name      = "AMI Jenkins-Slave (${var.public_domain_name})"
    Team      = "DevOps Toolchain"
  }
}




