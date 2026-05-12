output "master_public_ip" {
  description = "Public IP of the master node"
  value       = aws_instance.master.public_ip
}

output "master_private_ip" {
  description = "Private IP of the master node"
  value       = aws_instance.master.private_ip
}

output "worker_public_ips" {
  description = "Public IPs of all worker nodes"
  value       = aws_instance.workers[*].public_ip
}

output "worker_private_ips" {
  description = "Private IPs of all worker nodes"
  value       = aws_instance.workers[*].private_ip
}

output "ansible_inventory" {
  description = "Ready-to-use Ansible inventory — copy to ansible/inventory.ini"
  value = <<-EOT
[master]
k8s-master ansible_host=${aws_instance.master.public_ip} ansible_user=ec2-user ansible_ssh_private_key_file=~/.ssh/${var.key_name}.pem

[workers]
%{for i, ip in aws_instance.workers[*].public_ip~}
k8s-worker-${i + 1} ansible_host=${ip} ansible_user=ec2-user ansible_ssh_private_key_file=~/.ssh/${var.key_name}.pem
%{endfor~}

[all:children]
master
workers
EOT
}

output "ssh_master_command" {
  description = "SSH command to connect to master node"
  value       = "ssh -i ~/.ssh/${var.key_name}.pem ec2-user@${aws_instance.master.public_ip}"
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.k8s_vpc.id
}
