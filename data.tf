data "aws_ami" "redhat" {
  most_recent = true

  filter {
    name = "name"
    ami  = ["ami-08e637cea2f053dfa"]
  }

}