provider "aws" {
  region = "us-east-1"
}


# Security Group
resource "aws_security_group" "web_traffic" {
  name        = "Allow web traffic"
  description = "inbound ports for ssh and standard http and everything outbound"
  dynamic "ingress" {
    for_each = var.ingressrules
    iterator = port
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Terraform" = "true"
  }
}

module "key_pair" {
  source     = "terraform-aws-modules/key-pair/aws"
  key_name   = "jenkins"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC0TLsSPoiOSnac9MqVcaYh+NlJ0cqS4AKlNA9dh5CliG/jyaH1zUH6y4lWlqPBRBQ610UpKMST48cbbRVHYlZ7Suf415/Jp1zjM7NUS7H4USdbLI0qFL7OTHUSyyQBYG565EFsTMdUknVikQM6T2B1Dbs46JoRubfNlKg94YQljNl7inBFiks+/DKxXpcq/p1znvUz/cdWP5C77tXx8RB0vpFLDTSw0jRc/legZ/VdcqSpZJFOION5F+7HkiM5YT3QYFdNuA9khCL+Iqwd2LgcHWF12nFn+TQXvt9yl4VyXeLqc9GQeknGartTRcGc+gyW+3iDNjhdTcjHmBJwlMMSIAbEKW3QT1n3PkiCgH37/Df3GVtGCPVKmo1jnyFHkotSjqnz6ixw7H1IXyOYq2ED9BtLScyc8Za0j+p+D5M5qTGeWaBoiwg1gnXr6QuTzegi/ei2GYSrnNe0vmBEtMj+ctViXvV3TBn783lg+nNafOx00/T1snSH5Q2BvUESDB0= root@ip-172-31-85-18"
}

# resource block
resource "aws_instance" "jenkins" {
  ami             = data.aws_ami.redhat.id
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.web_traffic.name]
  key_name        = "jenkins"

}

resource "null_resource" "configure_nfs" {
  depends_on = [aws_instance.jenkins]
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(var.private_key)
    host        = aws_instance.jenkins.public_ip
    timeout     = "20s"
  }


  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y jenkins java-11-openjdk-devel",
      "sudo yum -y install wget",
      "sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo",
      "sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key",
      "sudo yum upgrade -y",
      "sudo yum install jenkins -y",
      "sudo systemctl start jenkins",
    ]
  }
}