resource "aws_instance" "chachat-api-ec2" {
  count         = 1
  instance_type = "t2.micro"
  ami = "ami-0ce107ae7af2e92b5"
  vpc_security_group_ids = [aws_security_group.chachat-api-security-group.id]
  subnet_id = aws_subnet.chachat-api-subnet-1a.id
  tags = {
    Name = "chachat-api"
  }
}
