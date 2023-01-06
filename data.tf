data "aws_ami" "redhat" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ami-08e637cea2f053dfa"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["amazon"]

}