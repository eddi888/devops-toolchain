
resource "aws_instance" "nexus" {
  ami                         = data.aws_ami.ubuntu.id
  availability_zone           = var.availability_zone
  instance_type               = "t3.medium"
  subnet_id                   = aws_subnet.subnet1.id
  associate_public_ip_address = true
  key_name                    = "admin"
  vpc_security_group_ids = [aws_security_group.all_out.id,
                            aws_security_group.ssh_in.id,
							aws_security_group.nexus_in.id,
                            aws_security_group.ping_in.id]
  
  tags = {
    Name      = "Nexus (${var.public_domain_name})"
    Team      = "DevOps Toolchain"
    Volume    = aws_ebs_volume.ebs_nexus.id
  }

}

resource "aws_ebs_volume" "ebs_nexus" {
  availability_zone = var.availability_zone
  size              = 5		//TODO lsblk AND resize2fs /dev/nvme?n?
  type              = "gp2"
  tags = {
    Name      = "Dynamic Nexus Volume (${var.public_domain_name})"
    Team      = "DevOps Toolchain"
  }
}

resource "aws_volume_attachment" "ebs_at_nexus" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.ebs_nexus.id
  instance_id = aws_instance.nexus.id
  
  connection {
	type        = "ssh"
	user        = "ubuntu"
	private_key = file(var.private_admin_key_file)
	host        = aws_instance.nexus.public_ip
  }
  
  provisioner "file" {
    source      = "machine-nexus/"
    destination = "/home/ubuntu/"
  }
  
  provisioner "remote-exec" {
    inline = ["sudo chmod +x /home/ubuntu/nexus-provisioner.sh",
	          "sudo /home/ubuntu/nexus-provisioner.sh ${aws_ebs_volume.ebs_nexus.id} NEXUS_VOL /storage"]
  }
}


