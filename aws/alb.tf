# ALB
resource "aws_lb" "chachat-api-alb" {
  name = "chachat-api-alb"
  #falseを指定するとインターネット向け,trueを指定すると内部向け
  internal           = false
  load_balancer_type = "application"
  security_groups = [
    aws_security_group.chachat-api-alb-security-group.id
  ]

  subnets = [
    aws_subnet.chachat-api-subnet-1a.id,
    aws_subnet.chachat-api-subnet-1c.id,
  ]
}

# ターゲットグループ
resource "aws_lb_target_group" "chachat-api-alb-target-group" {
  name     = "chachat-api-alb-target-group"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.chachat-api-vpc.id

  health_check {
    path = "/"
  }
}
# ターゲットグループをインスタンスに紐づける
resource "aws_lb_target_group_attachment" "chachat-api-alb-target-group-attachment_1a" {
  target_group_arn = aws_lb_target_group.chachat-api-alb-target-group.arn
  target_id        = aws_instance.chachat-api-web-ec2[0].id
  port             = 3000
}

# ALBのリスナー
resource "aws_lb_listener" "chachat-api-alb-listener" {
  load_balancer_arn = aws_lb.chachat-api-alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  # 各自が事前にACMに登録しておいた証明書のarnを指定する
  certificate_arn = "arn:aws:acm:ap-northeast-1:569113468865:certificate/f71488ad-72de-498e-b182-c7f1597b0149"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.chachat-api-alb-target-group.arn
  }
}

# リスナールール
resource "aws_lb_listener_rule" "chachat-api-alb-listener-ruler" {
  listener_arn = aws_lb_listener.chachat-api-alb-listener.arn
  priority     = 99
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.chachat-api-alb-target-group.arn
  }
  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}
