resource "aws_security_group" "sercurity_group" {
  name = "rds-security-group"
  ingress {
    from_port    = "5432"
    to_port     = "5432"
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
    Name = "rds-security-group"
  }
}
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds_subnet_group"
  subnet_ids = var.subnet_ids
  tags = {
    Name = "rds_subnet_group"
  }
}
resource "aws_db_instance" "default" {
  identifier              = "siva-postgres-db"
  allocated_storage       = var.allocate_storage
  engine                  = var.db_engine
  parameter_group_name = "default.${var.db_engine}${var.db_engine_pggroup}"
  engine_version          = var.db_engine_version
  instance_class          = var.db_instance_class
  db_name                 = var.db_instance_name
  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.sercurity_group.id]
  backup_retention_period = var.db_backup_retention_period
  backup_window           = var.db_backup_window
  maintenance_window      = var.db_maintenence_period
  skip_final_snapshot     = true
  tags = {
    Name = "terraform-rds-instance"
  }
}
