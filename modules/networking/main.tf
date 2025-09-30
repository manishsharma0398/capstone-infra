locals {
  vpc_name_with_slug   = lower("${var.tags.Project}-${var.environment_slug}")
  full_vpc_name        = lower("${var.tags.Project}-${var.environment_slug}-vpc")
  vpc_subnet_with_slug = lower("${var.tags.Project}-${var.environment_slug}-subnet")
}

resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags,
    { Name = "${local.full_vpc_name}" }
  )
}

# Public subnets
resource "aws_subnet" "public" {
  count             = length(var.public_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = merge(var.tags,
    { Name = "${local.vpc_subnet_with_slug}-public${count.index + 1}-${var.azs[count.index]}" }
  )
}

# Private subnets
resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = merge(var.tags,
    { Name = "${local.vpc_subnet_with_slug}-private${count.index + 1}-${var.azs[count.index]}" }
  )
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = merge(var.tags, { Name = "${local.vpc_name_with_slug}-igw" })
}

# Manage the default RTB and rename it as "public"
resource "aws_default_route_table" "public" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  tags = merge(var.tags, {
    Name = "${local.vpc_name_with_slug}-rtb-public"
  })
}

# Add internet access route to the default RTB
resource "aws_route" "public_internet_access" {
  route_table_id         = aws_default_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Associate all public subnets with the renamed default RTB
resource "aws_route_table_association" "public_assoc" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_default_route_table.public.id
}

# Private Route Tables — one per private subnet
resource "aws_route_table" "private" {
  count  = length(var.private_subnets)
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "${local.vpc_name_with_slug}-rtb-private${count.index + 1}-${var.azs[count.index]}"
  })
}

# Associate each private subnet with its own private RTB
resource "aws_route_table_association" "private_assoc" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# VPC Endpoint for S3 (Gateway type - attach to private RTB)
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"

  # Attach this one endpoint to all private RTBs
  route_table_ids = aws_route_table.private[*].id

  tags = merge(var.tags, {
    Name = "${local.vpc_name_with_slug}-vpce-s3"
  })
}
