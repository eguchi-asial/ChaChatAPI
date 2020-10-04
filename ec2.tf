resource "aws_instance" "sandbox" {
  count         = 1
  instance_type = "t2.micro"
  tags = {
    Name = "chachat-api"
  }
}
