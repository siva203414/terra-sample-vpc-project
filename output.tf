output "web-server-1-public-ip" {
  value = aws_instance.myinstance-1.public_ip
}
output "web-server-2-public-ip" {
  value = aws_instance.myinstance-2.public_ip
}
output "loadbalancerdns" {
  value = aws_lb.my-lb.dns_name
}
