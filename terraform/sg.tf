module "vote_service_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "abhay-ter-sg"
  description = "Security group for user-service with custom ports open within VPC, and PostgreSQL publicly open"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks      = ["10.16.0.0/16"]
  ingress_rules            = ["https-443-tcp"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 27017
      to_port     = 27017
      protocol    = "tcp"
      description = "User-service ports"
      cidr_blocks = "10.16.0.0/16"
    },
    {
      rule        = "ssh-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}
