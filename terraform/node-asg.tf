module "asg" {
  source = "terraform-aws-modules/autoscaling/aws"

  name = "terraform-asg-abhay"

  min_size                  = 1
  max_size                  = 5
  desired_capacity          = 1
  wait_for_capacity_timeout = 0
  health_check_type         = "EC2"
  vpc_zone_identifier       = module.vpc.private_subnets

  instance_refresh = {
    strategy = "Rolling"
    preferences = {
      checkpoint_delay       = 600
      checkpoint_percentages = [35, 70, 100]
      instance_warmup        = 60
      min_healthy_percentage = 50
    }
    triggers = ["tag"]
  }

  # Launch template
  launch_template_name        = "terraform-lt-abhay"
  launch_template_description = "Launch template example"
  update_default_version      = true

  image_id          = "ami-081ce7683a7eae7a5"
  instance_type     = "t3a.small"
  key_name          = "terraform"
  user_data         = filebase64("fetch-cloudWatch-config.sh")
  ebs_optimized     = true
  enable_monitoring = true
  target_group_arns = module.alb.target_group_arns
  security_groups   = [resource.aws_security_group.Security-node-abhay.id]
  iam_instance_profile_name = "codedeploy_role_for_ec2"
  # IAM role & instance profile

}

resource "aws_security_group" "Security-node-abhay" {
  name        = "security-node-abhay"
  description = "Allow TLS inbound and outbund traffic"
  vpc_id      = module.vpc.vpc_id
  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.pritunl-sg.id]
    #cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "TLS from VPC"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    security_groups = [aws_security_group.security-alb-abhay-sg.id]
    #cidr_blocks = [module.vpc.vpc_cidr_block]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name  = "security-node-abhay"
    owner = "abhay"
  }
}
