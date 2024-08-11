# Output the IAM user names
output "iam_user_names" {
  description = "The names of the IAM users created"
  value       = aws_iam_user.iam_users[*].name  # Outputs the names of all created IAM users
}

# Output the IAM group names
output "iam_group_names" {
  description = "The names of the IAM groups created"
  value       = aws_iam_group.iam_groups[*].name  # Outputs the names of all created IAM groups
}

# Output the ARNs of the policies attached to each IAM group
output "iam_group_policy_arns" {
  description = "The ARNs of the policies attached to each IAM group"
  value = {
    "S3-Support"  = aws_iam_group_policy_attachment.S3_Support_Attach.policy_arn
    "EC2-Support" = aws_iam_group_policy_attachment.EC2_Support_Attach.policy_arn
    "EC2-Admin"   = aws_iam_group_policy_attachment.EC2_Admin_Attach.policy_arn
  }
}

# Output the ARNs of the IAM users
output "iam_user_arns" {
  description = "The ARNs of the IAM users created"
  value       = aws_iam_user.iam_users[*].arn  # Outputs the ARNs of all created IAM users
}

# Output the IAM login profiles
output "iam_user_login_profiles" {
  description = "The login profiles of the IAM users created"
  value       = aws_iam_user_login_profile.login_profiles[*].user  # Outputs the login profiles of all created IAM users
}

# Output the ARNs of the IAM policies created
output "iam_policy_arns" {
  description = "The ARNs of the IAM policies created"
  value = [
    aws_iam_policy.S3_Support_Policy.arn,  # S3 Support Policy ARN
    aws_iam_policy.EC2_Support_Policy.arn, # EC2 Support Policy ARN
    aws_iam_policy.EC2_Admin_Policy.arn    # EC2 Admin Policy ARN
  ]
}

# Output the VPC ID
output "vpc_id" {
  description = "The ID of the created VPC"
  value       = aws_vpc.myvpc.id
}

# Output the Subnet IDs
output "subnet_ids" {
  description = "The IDs of the created subnets"
  value       = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
}

# Output the Security Group ID
output "security_group_id" {
  description = "The ID of the created Security Group"
  value       = aws_security_group.mysg.id
}

# Output the Load Balancer DNS Name
output "load_balancer_dns" {
  description = "The DNS name of the Load Balancer"
  value       = aws_lb.mylb.dns_name
}

# Output the S3 Bucket Name
output "s3_bucket_name" {
  description = "The name of the created S3 bucket"
  value       = aws_s3_bucket.example.bucket
}