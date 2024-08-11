# Override the default region if needed
aws_region = "us-east-2"

# List of IAM users to create
iam_users = ["pooja", "venkat", "vamsi"]

# List of IAM groups to create
iam_groups = ["S3-Support", "EC2-Support", "EC2-Admin"]

# Specify the CIDR block for Subnet 1
subnet1_cidr = "10.0.0.0/24" 

# Specify the CIDR block for Subnet 2
subnet2_cidr = "10.0.1.0/24" 

# CIDR block for the VPC
cidr_block_value = "10.0.0.0/16"

# Example AMI ID (replace with actual)
ami_value = "ami-0c55b159cbfafe1f0"

# Instance type for EC2 instances
instance_type_value = "t2.micro"