variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "Amazon Linux 2 AMI ID - change based on your region"
  type        = string
  default     = "ami-0c02fb55956c7d316" # us-east-1 Amazon Linux 2
}

variable "instance_type_master" {
  description = "Instance type for master node"
  type        = string
  default     = "t3.medium"
}

variable "instance_type_worker" {
  description = "Instance type for worker nodes"
  type        = string
  default     = "t3.medium"
}

variable "worker_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 2
}

variable "key_name" {
  description = "AWS Key Pair name (must exist in AWS already)"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "Public subnet CIDR block"
  type        = string
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "Availability zone for subnet"
  type        = string
  default     = "us-east-1a"
}

variable "project_name" {
  description = "Project name used for resource tagging"
  type        = string
  default     = "k8s-cluster"
}
