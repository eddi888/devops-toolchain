
resource "aws_instance" "jenkins" {
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
    Name      = "Jenkins-Master"
    Team      = "DevOps Toolchain"
    Volume    = aws_ebs_volume.ebs_jenkins.id
  }

}

resource "aws_ebs_volume" "ebs_jenkins" {
  availability_zone = var.availability_zone 
  size              = 1
  type              = "gp2"
  tags = {
    Name      = "Dynamic Jenkins Volume"
    Team      = "DevOps Toolchain"
  }
}

resource "aws_volume_attachment" "ebs_at_jenkins" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.ebs_jenkins.id
  instance_id = aws_instance.jenkins.id
  
  connection {
		type        = "ssh"
		user        = "ubuntu"
		private_key = file(var.private_admin_key_file)
		host        = aws_instance.jenkins.public_ip
  }
	
  provisioner "file" {
    source      = "machine-jenkins/"
    destination = "/home/ubuntu/"
  }
  
  provisioner "remote-exec" {
    inline = ["sudo chmod +x /home/ubuntu/jenkins-provisioner.sh",
	          "sudo /home/ubuntu/jenkins-provisioner.sh ${aws_ebs_volume.ebs_jenkins.id} JENKINS_VOL /storage"]
  }

}
