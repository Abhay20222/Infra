module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  for_each = toset(["one", "two", "three"])

  name = "instance-${each.key}"

  ami                    = "ami-0ada6d94f396377f2"
  instance_type          = "t3a.micro"
  key_name               = "terraform"
  monitoring             = true
  vpc_security_group_ids = [resource.aws_security_group.Security-mongo-abhay.id]
  subnet_id              = module.vpc.private_subnets[0]
  user_data              = filebase64("install-mongo.sh")

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Name        = "abhay-mongo"
  }
}

resource "aws_security_group" "Security-mongo-abhay" {
  name        = "security-mongo-abhay"
  description = "Allow TLS inbound and outbund traffic"
  vpc_id      = module.vpc.vpc_id
  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    #security_group_id =  [resource.aws_security_group.Security-node-abhay.id]
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }
  ingress {
    description = "TLS from VPC"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name  = "security-mongo-abhay"
    owner = "abhay"
  }
}
