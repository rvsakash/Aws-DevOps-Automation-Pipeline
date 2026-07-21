output "instance_public_ips" {
  description = "Dynamic public IPs of both web servers for Ansible inventory management"
  value       = aws_instance.web_servers[*].public_ip
}

output "alb_dns_name" {
  description = "Public URL of the Application Load Balancer to access the Blue-Green web app"
  value       = aws_lb.app_alb.dns_name
}
