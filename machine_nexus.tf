
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
    Name      = "Nexus"
    Team      = "DevOps Toolchain"
    Volume    = aws_ebs_volume.ebs_nexus.id
  }
  
  connection {
    type        = "ssh"
    user        = "ubuntu"
	private_key = file(var.private_admin_key_file)
	host        = self.public_ip
  }

  provisioner "file" {
    source      = "scripts/nexus-provisioner.py"
    destination = "/home/ubuntu/nexus-provisioner.py"
  }
  
  provisioner "remote-exec" {
    inline = ["sudo apt-get update",
	          "sudo apt-get upgrade -y",
			  "sudo apt-get install -y python",
			  "sudo python /home/ubuntu/nexus-provisioner.py ${aws_ebs_volume.ebs_nexus.id}"]
  }

}

resource "aws_ebs_volume" "ebs_nexus" {
  availability_zone = var.availability_zone
  size              = 1
  type              = "gp2"
  tags = {
    Name      = "Dynamic Nexus Volume"
    Team      = "DevOps Toolchain"
  }
}

resource "aws_volume_attachment" "ebs_at_nexus" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.ebs_nexus.id
  instance_id = aws_instance.nexus.id
}
