data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_security_group" "bastion-sg" {
  vpc_id = module.vpc.vpc_id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
}

resource "tls_private_key" "bastion-key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "bastion-key-pair" {
  key_name   = "${var.prefix}-key"
  public_key = tls_private_key.bastion-key.public_key_openssh
}

resource "local_file" "bastion_private_key" {
  content  = tls_private_key.bastion-key.private_key_pem
  filename = "${path.module}/bastion_key.pem"
}

resource "aws_iam_role" "bastion_role" {
  name = "${var.prefix}-bastion-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Sid       = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "role_attachment" {
  role       = aws_iam_role.bastion_role.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

resource "aws_iam_instance_profile" "bastion_profile" {
  name = "${var.prefix}-instance-profile"
  role = aws_iam_role.bastion_role.name
}

resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.small"
  subnet_id              = module.vpc.public_subnets[0]
  key_name               = aws_key_pair.bastion-key-pair.key_name
  iam_instance_profile   = aws_iam_instance_profile.bastion_profile.id

  vpc_security_group_ids = [
    module.eks.cluster_security_group_id,
    module.eks.node_security_group_id,  
    aws_security_group.bastion-sg.id
  ]

  tags = {
    "Name" = "${var.prefix}-bastion"
  }
}
