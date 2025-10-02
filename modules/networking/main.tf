# modules\networking\main.tf

locals {
  vpc_name_with_slug   = lower("${var.tags.Project}-${var.environment_slug}")
  full_vpc_name        = lower("${var.tags.Project}-${var.environment_slug}-vpc")
  vpc_subnet_with_slug = lower("${var.tags.Project}-${var.environment_slug}-subnet")
}

# ------------------------------
# VPC
# ------------------------------
resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name = local.full_vpc_name
  })
}

# ------------------------------
# Subnets
# ------------------------------
resource "aws_subnet" "public" {
  count             = length(var.public_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = merge(var.tags, {
    Name   = "${local.vpc_subnet_with_slug}-public${count.index + 1}-${var.azs[count.index]}"
    Subnet = "Public"
  })
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = merge(var.tags, {
    Name   = "${local.vpc_subnet_with_slug}-private${count.index + 1}-${var.azs[count.index]}"
    Subnet = "Private"
  })
}

# ------------------------------
# Internet Gateway
# ------------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = merge(var.tags, { Name = "${local.vpc_name_with_slug}-igw" })
}

# ------------------------------
# Public Route Table (default RTB renamed)
# ------------------------------
resource "aws_default_route_table" "public" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  tags = merge(var.tags, {
    Name = "${local.vpc_name_with_slug}-rtb-public"
  })
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_default_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_assoc" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_default_route_table.public.id
}

# ------------------------------
# Private Route Tables — one per private subnet
# ------------------------------
resource "aws_route_table" "private" {
  count  = length(var.private_subnets)
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "${local.vpc_name_with_slug}-rtb-private${count.index + 1}-${var.azs[count.index]}"
  })
}

# Associate each private subnet with its own RTB
resource "aws_route_table_association" "private_assoc" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# ------------------------------
# VPC Endpoint (S3)
# ------------------------------
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"

  # Attach this one endpoint to ALL private RTBs
  route_table_ids = aws_route_table.private[*].id

  tags = merge(var.tags, {
    Name = "${local.vpc_name_with_slug}-vpce-s3"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# ------------------------------
# VPC Endpoint (Secrets Manager)
# ------------------------------
resource "aws_vpc_endpoint" "secrets_manager" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.secretsmanager"
  vpc_endpoint_type = "Interface"

  subnet_ids         = aws_subnet.private[*].id
  security_group_ids = [aws_security_group.vpce_secrets.id]

  private_dns_enabled = true

  # Enable DNS resolution (important!)
  dns_options {
    dns_record_ip_type = "ipv4"
  }

  tags = merge(var.tags, {
    Name = "${local.vpc_name_with_slug}-vpce-secrets-manager"
  })

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_security_group" "vpce_secrets" {
  name        = "${local.vpc_name_with_slug}-vpce-secrets-sg"
  description = "Secrets Manager VPC Endpoint SG"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow VPC private subnets to access Secrets Manager"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block] # Use VPC CIDR instead of just private subnets
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${local.vpc_name_with_slug}-vpce-secrets-sg"
  })
}
