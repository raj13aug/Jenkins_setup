data "aws_ami" "redhat" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ami-08e637cea2f053dfa"]
  }

}