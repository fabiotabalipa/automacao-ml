resource "aws_security_group" "custom_ips" {
  name_prefix = "tf_ml_playground_"
  description = "Allow custom IPs to access ML Playground"
  
	ingress	{
		description = "Jupyter Lab from custom IPs"
		from_port   = 8443
		to_port     = 8443
		protocol    = "tcp"
		cidr_blocks = var.allowed_ips
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
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "jupyter_lab" {
  ami = "ami-03a49dfc77581833f"
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
		source = "./files/jupyter.service"
		destination = "/home/ec2-user/jupyter.service"
	}

	provisioner "file" {
		source = "./files/stop_idle.py"
		destination = "/home/ec2-user/stop_idle.py"
	}

	provisioner "file" {
		source = "./files/jupyter_notebook_config.json"
		destination = "/home/ec2-user/jupyter_notebook_config.json"
	}

	provisioner "remote-exec" {
		inline = [
			"mkdir ~/notebooks",
			"/usr/bin/python3 -m pip install ec2-metadata --quiet",
			"crontab -r 2> /dev/null",
			"echo \"*/1 * * * * /usr/bin/python3 $HOME/stop_idle.py\" | crontab -",
			"sudo mv ~/jupyter.service /etc/systemd/system/jupyter.service",
			"sudo systemctl enable jupyter.service",
			"sudo systemctl start jupyter.service"
		]
	}

	depends_on = [ 
		aws_security_group.custom_ips,
		aws_iam_instance_profile.service_ec2
	]
}
