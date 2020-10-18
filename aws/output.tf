# apply後にElastic IPのパブリックIPを出力する
output "elastic_web_ip" {
  value = aws_eip.chachat-api-web-elastic-ip.public_ip
}

output "elastic_fumidai_ip" {
  value = aws_eip.chachat-api-fumidai-elastic-ip.public_ip
}
