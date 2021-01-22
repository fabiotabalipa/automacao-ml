resource "aws_security_group" "custom_ips" {
  name_prefix = "tf_ml_playground_"
  description = "Allow custom IPs to access ML Playground"
  
	ingress	{
		description = "Jupyter Lab from custom IPs"
		from_port   = 8443
		to_port     = 8443
		protocol    = "tcp"
		cidr_blocks = [
			"0.0.0.0/0"
		]
		ipv6_cidr_blocks = [
			"::/0"
		]
	}

	ingress {
		description = "SSH from custom IPs"
		from_port   = 22
		to_port     = 22
		protocol    = "tcp"
		cidr_blocks = var.allowed_ips
	}

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [
			"0.0.0.0/0"
		]
  }
}

resource "aws_instance" "jupyter_lab" {
  ami = var.ami
  instance_type = var.instance_type
	key_name = var.key_name
	security_groups = [ 
		aws_security_group.custom_ips.name
	]
	iam_instance_profile = aws_iam_instance_profile.service_ec2.name
  tags = {
    Name = "Jupyter Lab (ML)"
  }

	connection {
		type = "ssh"
		host = self.public_dns
		user = "ec2-user"
		private_key = file(var.identity_file_path)
	}

	provisioner "file" {
		source = "./files/auto_commit.sh"
		destination = "/home/ec2-user/auto_commit.sh"
	}

	provisioner "file" {
		source = "./files/jupyter.service"
		destination = "/home/ec2-user/jupyter.service"
	}

	provisioner "file" {
		source = "./files/jupyter_cfg_gen.py"
		destination = "/home/ec2-user/jupyter_cfg_gen.py"
	}

	provisioner "file" {
		source = "./files/stop_idle.py"
		destination = "/home/ec2-user/stop_idle.py"
	}

	provisioner "remote-exec" {
		inline = [
			"git config --global user.name \"cron job\"",
			"git clone --quiet https://${var.github_access_token}@github.com/${var.github_user_name}/${var.github_repo_name}.git > /dev/null",
			"/usr/bin/python3 -m pip install ec2-metadata --quiet",
			"/usr/bin/python3 /home/ec2-user/jupyter_cfg_gen.py",
			"rm /home/ec2-user/jupyter_cfg_gen.py",
			"crontab -r 2> /dev/null",
			"chmod +x ./auto_commit.sh",
			"{ echo \"*/1 * * * * /usr/bin/python3 $HOME/stop_idle.py\"; echo \"*/3 * * * * /home/ec2-user/auto_commit.sh\"; } | crontab -",
			"sudo mv ~/jupyter.service /etc/systemd/system/jupyter.service",
			"sudo systemctl enable jupyter.service",
			"sudo systemctl start jupyter.service"
		]
	}

	depends_on = [ 
		aws_security_group.custom_ips,
		aws_iam_instance_profile.service_ec2,
		local_file.auto_commit_sh,
		local_file.jupyter_cfg_gen_py,
		local_file.jupyter_service
	]
}
