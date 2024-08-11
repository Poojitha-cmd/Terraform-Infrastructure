# Define the AWS region variable
variable "aws_region" {
  description = "The AWS region where resources will be created"
  type        = string
  // default     = "us-east-2"  # Default region is Ohio
}

# Define the list of IAM users
variable "iam_users" {
  description = "List of IAM users to create"
  type        = list(string)
 // default     = ["pooja", "venkat", "vamsi"]  # Default list of users
}

# Define the list of IAM groups
variable "iam_groups" {
  description = "List of IAM groups to create"
  type        = list(string)
  // default     = ["S3-Support", "EC2-Support", "EC2-Admin"]  # Default list of groups
}

# Define the CIDR block for Subnet 1
variable "subnet1_cidr" {
  description = "CIDR block for Subnet 1"
  type        = string
  default     = "10.0.0.0/24"
}

# Define the CIDR block for Subnet 2
variable "subnet2_cidr" {
  description = "CIDR block for Subnet 2"
  type        = string
  default     = "10.0.1.0/24"
}

# Define the CIDR block for the VPC
variable "cidr_block_value" {
  description = "CIDR block for the VPC"
  type        = string
}

# Define the AMI ID for the EC2 instances
variable "ami_value" {
  description = "AMI ID for the EC2 instances"
  type        = string
}

# Define the instance type for the EC2 instances
variable "instance_type_value" {
  description = "Instance type for the EC2 instances"
  type        = string
}