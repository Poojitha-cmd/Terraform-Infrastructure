# Create IAM users from the list
resource "aws_iam_user" "iam_users" {
  count = length(var.iam_users)  # Iterate over the list of users
  name  = var.iam_users[count.index]  # Create an IAM user with the name from the list
}

# Create IAM groups from the list
resource "aws_iam_group" "iam_groups" {
  count = length(var.iam_groups)  # Iterate over the list of groups
  name  = var.iam_groups[count.index]  # Create an IAM group with the name from the list
}

# Associate IAM users with IAM groups
resource "aws_iam_user_group_membership" "group_memberships" {
  count  = length(var.iam_users)  # Iterate over the list of users
  user   = aws_iam_user.iam_users[count.index].name  # Assign the user to the corresponding group
  groups = [element(var.iam_groups, count.index)]  # Assign each user to a specific group
}

# Add Login Profiles with Initial Passwords for each user
resource "aws_iam_user_login_profile" "login_profiles" {
  count = length(var.iam_users)  # Iterate over the list of users
  user  = aws_iam_user.iam_users[count.index].name  # Create a login profile for the user
  password_reset_required = false  # Specify that the user doesn't need to reset the password on first login
}

# Define IAM Policies

# S3 Read only policy
resource "aws_iam_policy" "S3_Support_Policy" {
  name        = "S3-Support-Policy"
  description = "Policy for S3-Support group"
  policy      = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:Get*",
                "s3:List*",
                "s3:Describe*",
                "s3-object-lambda:Get*",
                "s3-object-lambda:List*"
            ],
            "Resource": "*"
        }
    ]
  })
}

# EC2 Read only policy
resource "aws_iam_policy" "EC2_Support_Policy" {
  name        = "EC2-Support-Policy"
  description = "Policy for EC2-Support group"
  policy      = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "ec2:Describe*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "elasticloadbalancing:Describe*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "cloudwatch:ListMetrics",
                "cloudwatch:GetMetricStatistics",
                "cloudwatch:Describe*"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "autoscaling:Describe*",
            "Resource": "*"
        }
    ]
  })
}

# EC2 Full Access Policy
resource "aws_iam_policy" "EC2_Admin_Policy" {
  name        = "EC2-Admin-Policy"
  description = "Policy for EC2-Admin group"
  policy      = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "ec2:*",
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "elasticloadbalancing:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "cloudwatch:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "autoscaling:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "iam:CreateServiceLinkedRole",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "iam:AWSServiceName": [
                        "autoscaling.amazonaws.com",
                        "ec2scheduled.amazonaws.com",
                        "elasticloadbalancing.amazonaws.com",
                        "spot.amazonaws.com",
                        "spotfleet.amazonaws.com",
                        "transitgateway.amazonaws.com"
                    ]
                }
            }
        }
    ]
  })
}

# Attach Policies to Groups
resource "aws_iam_group_policy_attachment" "S3_Support_Attach" {
  group      = aws_iam_group.iam_groups[0].name  # Attach policy to the S3-Support group
  policy_arn = aws_iam_policy.S3_Support_Policy.arn
}

resource "aws_iam_group_policy_attachment" "EC2_Support_Attach" {
  group      = aws_iam_group.iam_groups[1].name  # Attach policy to the EC2-Support group
  policy_arn = aws_iam_policy.EC2_Support_Policy.arn
}

resource "aws_iam_group_policy_attachment" "EC2_Admin_Attach" {
  group      = aws_iam_group.iam_groups[2].name  # Attach policy to the EC2-Admin group
  policy_arn = aws_iam_policy.EC2_Admin_Policy.arn
}


# Create a VPC
resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr_block_value # VPC CIDR block from variables.tf
}

# Create two subnets in different availability zones
resource "aws_subnet" "subnet1" {
  vpc_id = aws_vpc.myvpc.id
  cidr_block = var.subnet1_cidr # CIDR block for Subnet 1
  availability_zone = "us-east-2a" # Availability Zone for Subnet 1
  map_public_ip_on_launch = true # Automatically assign a public IP to instances launched in this subnet

  tags = {
    Name = "Subnet-1"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id = aws_vpc.myvpc.id
  cidr_block = var.subnet2_cidr # CIDR block for Subnet 2
  availability_zone = "us-east-2b" # Availability Zone for Subnet 2
  map_public_ip_on_launch = true # Automatically assign a public IP to instances launched in this subnet

  tags = {
    Name = "Subnet-2"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "internetgateway" {
  vpc_id = aws_vpc.myvpc.id
}

# Create a Route Table with a default route to the Internet
resource "aws_route_table" "routetable" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internetgateway.id
  }
}

# Associate Subnets with the Route Table
resource "aws_route_table_association" "routetableassociation1" {
  subnet_id = aws_subnet.subnet1.id
  route_table_id = aws_route_table.routetable.id
}

resource "aws_route_table_association" "routetableassociation2" {
  subnet_id = aws_subnet.subnet2.id
  route_table_id = aws_route_table.routetable.id
}

# Create a Security Group
resource "aws_security_group" "mysg" {
  name = "mysg"
  description = "Allow mysg inbound traffic"
  vpc_id = aws_vpc.myvpc.id

  ingress {
    description = "HTTP from vpc"
    from_port   = 80
    to_port     = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    name = "Web-sg"
  }
}

# Create an S3 Bucket
resource "aws_s3_bucket" "example" {
  bucket = "trainingpractise"
}

# Launch two EC2 Instances in different subnets
resource "aws_instance" "training" {
  ami           = var.ami_value
  instance_type = var.instance_type_value
  vpc_security_group_ids = [aws_security_group.mysg.id]
  subnet_id = aws_subnet.subnet1.id
} 

resource "aws_instance" "training1" {
  ami           = var.ami_value
  instance_type = var.instance_type_value
  vpc_security_group_ids = [aws_security_group.mysg.id]
  subnet_id = aws_subnet.subnet2.id
} 

# Create a Load Balancer
resource "aws_lb" "mylb" {
  name = "mylb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.mysg.id]
  subnets = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]

  tags = {
    name = "my-lb"
  }
}

# Create a Target Group for the Load Balancer
resource "aws_lb_target_group" "tg" {
  name = "TG"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.myvpc.id

  health_check {
    path = "/"
    port = "traffic-port"
  } 
}

# Attach EC2 Instances to the Target Group
resource "aws_lb_target_group_attachment" "attach1" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id = aws_instance.training.id
  port = 80
}

resource "aws_lb_target_group_attachment" "attach2" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id = aws_instance.training1.id
  port = 80
}

# Create a Listener for the Load Balancer
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.mylb.arn
  port = 80
  protocol = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.tg.arn
    type = "forward"
  }
}



