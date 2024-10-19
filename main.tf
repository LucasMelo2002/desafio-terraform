
provider "aws" {
  region = "us-east-1"
}

# Criando a VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "MainVPC"
  }
}

# Criando uma Subnet dentro da VPC
resource "aws_subnet" "main_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "MainSubnet"
  }
}

# Criando um Security Group para a instância EC2
resource "aws_security_group" "main_sg" {
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["YOUR_IP/32"]  # Substituir YOUR_IP pelo seu endereço IP para segurança
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "MainSecurityGroup"
  }
}

# Criando uma Key Pair
resource "aws_key_pair" "main_key" {
  key_name   = "main_key"
  public_key = file("~/.ssh/id_rsa.pub")
}

# Criando a instância EC2
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2 AMI
  instance_type = "t2.micro"

  security_groups = [aws_security_group.main_sg.name]
  key_name        = aws_key_pair.main_key.key_name

  # Script para instalar e iniciar o Nginx automaticamente
  user_data = <<-EOF
    #!/bin/bash
    sudo apt update
    sudo apt install -y nginx
    sudo systemctl start nginx
    sudo systemctl enable nginx
  EOF

  tags = {
    Name = "WebServer"
  }
}

# Monitoramento básico com CloudWatch (opcional)
resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name          = "HighCPUUtilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"
  actions_enabled     = true
  alarm_actions       = []
  ok_actions          = []
  insufficient_data_actions = []

  dimensions = {
    InstanceId = aws_instance.web.id
  }
}

# Backup automático (opcional)
resource "aws_backup_plan" "ec2_backup" {
  name = "EC2BackupPlan"

  rule {
    rule_name         = "DailyBackup"
    target_vault_name = "Default"
    schedule          = "cron(0 12 * * ? *)"
  }
}

resource "aws_backup_selection" "ec2_backup_selection" {
  iam_role_arn = "arn:aws:iam::123456789012:role/AWSBackupDefaultServiceRole"
  name         = "EC2Backup"
  plan_id      = aws_backup_plan.ec2_backup.id

  resources = [
    aws_instance.web.arn
  ]
}
