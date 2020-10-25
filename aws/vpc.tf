# ====================
#
# VPC
#
# ====================
resource "aws_vpc" "chachat-api-vpc" {
  cidr_block = "192.168.0.0/16"
  tags = {
    Name = "chachat-api-vpc"
  }
}

# ====================
#
# subnet 1a
#
# ====================
resource "aws_subnet" "chachat-api-subnet-1a" {
  vpc_id            = aws_vpc.chachat-api-vpc.id
  cidr_block        = "192.168.0.0/24"
  availability_zone = "ap-northeast-1a"
  tags = {
    Name = "chachat-api-subnet-1a"
  }
}


# ====================
#
# subnet 1c
#
# ====================
resource "aws_subnet" "chachat-api-subnet-1c" {
  vpc_id            = aws_vpc.chachat-api-vpc.id
  cidr_block        = "192.168.1.0/24"
  availability_zone = "ap-northeast-1c"
  tags = {
    Name = "chachat-api-subnet-1c"
  }
}

# ====================
#
# Internet Gateway
#
# ====================
resource "aws_internet_gateway" "chachat-api-internet-gateway" {
  vpc_id = aws_vpc.chachat-api-vpc.id

  tags = {
    Name = "chachat-api-internet-gateway"
  }
}

# ====================
#
# Route Table
#
# ====================
resource "aws_route_table" "chachat-api-route-table" {
  vpc_id = aws_vpc.chachat-api-vpc.id

  tags = {
    Name = "chachat-api-route-table"
  }
}

resource "aws_route" "chachat-api-route" {
  gateway_id             = aws_internet_gateway.chachat-api-internet-gateway.id
  route_table_id         = aws_route_table.chachat-api-route-table.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "chachat-api-route-table-association" {
  subnet_id      = aws_subnet.chachat-api-subnet-1a.id
  route_table_id = aws_route_table.chachat-api-route-table.id
}

resource "aws_route_table_association" "chachat-api-route-table-association-a" {
  subnet_id      = aws_subnet.chachat-api-subnet-1a.id
  route_table_id = aws_route_table.chachat-api-route-table.id
}

resource "aws_route_table_association" "chachat-api-route-table-association-c" {
  subnet_id      = aws_subnet.chachat-api-subnet-1c.id
  route_table_id = aws_route_table.chachat-api-route-table.id
}

# ====================
#
# Security Group
#
# ====================
resource "aws_security_group" "chachat-api-web-security-group" {
  vpc_id = aws_vpc.chachat-api-vpc.id
  name   = "chachat-api-web-security-group"

  tags = {
    Name = "chachat-api-web-security-group"
  }
}

# web: インバウンドルール(web) apiは3000だが、websocketでpollingに80が使われるため80と3000が必要
resource "aws_security_group_rule" "chchat-api-web-rule-in" {
  security_group_id = aws_security_group.chachat-api-web-security-group.id
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
}
resource "aws_security_group_rule" "chchat-api-api-rule-in" {
  security_group_id = aws_security_group.chachat-api-web-security-group.id
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 3000
  to_port           = 3000
  protocol          = "tcp"
}
# web-ssh 踏み出しからのsshのみを許可
resource "aws_security_group_rule" "chchat-api-web-ssh-rule-in" {
  security_group_id        = aws_security_group.chachat-api-web-security-group.id
  type                     = "ingress"
  source_security_group_id = aws_security_group.chachat-api-fumidai-security-group.id
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
}

# web: アウトバウンドルール(全開放)
resource "aws_security_group_rule" "chchat-api-web-rule-out" {
  security_group_id = aws_security_group.chachat-api-web-security-group.id
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
}

# 踏み台
resource "aws_security_group" "chachat-api-fumidai-security-group" {
  vpc_id = aws_vpc.chachat-api-vpc.id
  name   = "chachat-api-fumidai-security-group"

  tags = {
    Name = "chachat-api-fumidai-security-group"
  }
}

# 踏み台: インバウンドルール(ssh)
resource "aws_security_group_rule" "chchat-api-fumidai-rule-in" {
  security_group_id = aws_security_group.chachat-api-fumidai-security-group.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  cidr_blocks       = ["222.224.169.129/32"]
  protocol          = "tcp"
}

# 踏み台: アウトバウンドルール(全開放)
resource "aws_security_group_rule" "chchat-api-fumidai-rule-out" {
  security_group_id = aws_security_group.chachat-api-fumidai-security-group.id
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
}
