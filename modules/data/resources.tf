# modules/data/resources.tf

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
# Subnets (Private only)
# ------------------------------
resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = merge(var.tags, {
    Name = "${local.vpc_subnet_with_slug}-private${count.index + 1}-${var.azs[count.index]}"
  })
}

# ------------------------------
# Route Tables (Private only) — one per private subnet
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
