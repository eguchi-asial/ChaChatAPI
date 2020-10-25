# apply後にElastic IPのパブリックIPを出力する
output "elastic_web_ip" {
  value = aws_eip.chachat-api-web-elastic-ip.public_ip
}

output "elastic_web_private-ip" {
  value = aws_eip.chachat-api-web-elastic-ip.private_ip
}

output "elastic_fumidai_ip" {
  value = aws_eip.chachat-api-fumidai-elastic-ip.public_ip
}

output "elastic_alb_dns" {
  value = aws_lb.chachat-api-alb.dns_name
}
