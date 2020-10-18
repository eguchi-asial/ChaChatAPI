# webサーバ 踏み台からのSSHのみ許容
resource "aws_instance" "chachat-api-web-ec2" {
  count                       = 1
  instance_type               = "t2.micro"
  ami                         = "ami-0ce107ae7af2e92b5"
  vpc_security_group_ids      = [aws_security_group.chachat-api-web-security-group.id]
  subnet_id                   = aws_subnet.chachat-api-subnet-1a.id
  key_name                    = aws_key_pair.public-key.key_name
  associate_public_ip_address = "true"
  tags = {
    Name = "chachat-api-web"
  }
}

# Elastic IP
## https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip
resource "aws_eip" "chachat-api-web-elastic-ip" {
  instance   = aws_instance.chachat-api-web-ec2[0].id
  vpc        = true
  depends_on = [aws_internet_gateway.chachat-api-internet-gateway]
}

resource "aws_eip" "chachat-api-fumidai-elastic-ip" {
  instance   = aws_instance.chachat-api-fumidai-ec2[0].id
  vpc        = true
  depends_on = [aws_internet_gateway.chachat-api-internet-gateway]
}

# 踏み台ec2 固定IP帯からのみSSH可能
## ここからwebにssh可能
resource "aws_instance" "chachat-api-fumidai-ec2" {
  count                       = 1
  instance_type               = "t2.nano"
  ami                         = "ami-0ce107ae7af2e92b5"
  vpc_security_group_ids      = [aws_security_group.chachat-api-fumidai-security-group.id]
  subnet_id                   = aws_subnet.chachat-api-subnet-1c.id
  key_name                    = aws_key_pair.public-key.key_name
  associate_public_ip_address = "true"
  tags = {
    Name = "chachat-api-fumidai"
  }
}

# SSh用の公開鍵登録
resource "aws_key_pair" "public-key" {
  key_name   = "public-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDDqm14CfY/eKynvRpQXxp+3c08V9wBr8nSP0HwR2OCq2zOX5+mm+vu/Ei+OcDp1eIMj7UWzox42dKw1sZNKEoeyQSnMyLqfyQ+fPYsljJk27mpNQ5aiMjj93bXZiEIYq67QnURAOdOceagrY2prkDU4313OaNX4DN6D8cVAHaMRXMe0KazjT7/6fOv7ORkT0nv7rUuUXogLE+ZTYHXBzxGh85uw3DC9zu8ctXt0PsO4eXBzTri9YpA/OW7t10G2Vg2wuCJUjNxEaonbsH73/kcYo3iSRKwJkqVr3WTkBQXRJX3VifPAc7FRU2F3AnX1vFksDlDfBXKLKWvS1Y9oQGz eguchi@asial.co.jp"
}
