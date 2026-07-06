# ------------------------------------------------------------
# Amazon RDS (PostgreSQL Instance)
# ------------------------------------------------------------
resource "aws_db_subnet_group" "ramzy-eks-rds-subnet-group" {
  name       = "ramzy-eks-rds-subnet-group"
  subnet_ids = [data.aws_subnet.subnet-1.id, data.aws_subnet.subnet-2.id]

  tags = {
    Name = "ramzy-eks-rds-subnet-group"
    Owner = "Ramzy_Ahmed"
  }
}

resource "aws_security_group" "ramzy-eks-rds-sg" {
  name        = "ramzy-eks-rds-security-group"
  description = "Allow Postgres access from the EKS cluster"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Postgres"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ramzy-eks-rds-security-group"
    Owner = "Ramzy_Ahmed"
  }
}

resource "aws_db_instance" "ramzy-eks-postgres" {
  engine               = "postgres"
  engine_version       = "14.1"
  instance_class       = "db.t3.micro"
  identifier           = "ramzy-eks-postgres"
  name                 = "ecommercedb"
  username             = "ramzyadmin"
  password             = "SecurePass123!" # Replace with Terraform variable in production
  parameter_group_name = "default.postgres14"
  skip_final_snapshot  = true
  publicly_accessible  = true
  vpc_security_group_ids = [aws_security_group.ramzy-eks-rds-sg.id]
  db_subnet_group_name = aws_db_subnet_group.ramzy-eks-rds-subnet-group.name
  allocated_storage    = 20
  storage_type         = "gp2"

  tags = {
    Name = "ramzy-eks-postgres"
    Owner = "Ramzy_Ahmed"
  }
}

# ------------------------------------------------------------
# AWS Application Load Balancer (ALB)
# ------------------------------------------------------------
resource "aws_lb" "ramzy-eks-alb" {
  name               = "ramzy-eks-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.aws_security_group.selected.id]
  subnets            = [data.aws_subnet.subnet-1.id, data.aws_subnet.subnet-2.id]

  enable_deletion_protection = false

  tags = {
    Name = "ramzy-eks-alb"
    Owner = "Ramzy_Ahmed"
  }
}

resource "aws_lb_target_group" "ramzy-eks-frontend-tg" {
  name     = "ramzy-eks-frontend-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.main.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-299"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
  }

  tags = {
    Name = "ramzy-eks-frontend-tg"
    Owner = "Ramzy_Ahmed"
  }
}

resource "aws_lb_listener" "ramzy-eks-alb-http" {
  load_balancer_arn = aws_lb.ramzy-eks-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ramzy-eks-frontend-tg.arn
  }
}
