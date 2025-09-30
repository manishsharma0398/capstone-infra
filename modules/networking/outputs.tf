# VPC ID
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

# Public Subnets
output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

# Private Subnets
output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

# Public Route Table (default RTB renamed)
output "public_route_table_id" {
  description = "ID of the public route table (default RTB renamed)"
  value       = aws_default_route_table.public.id
}

# Private Route Tables (one per subnet)
output "private_route_table_ids" {
  description = "IDs of private route tables (one per private subnet)"
  value       = aws_route_table.private[*].id
}

# VPC Endpoint for S3
output "s3_vpc_endpoint_id" {
  description = "ID of the S3 VPC endpoint"
  value       = aws_vpc_endpoint.s3.id
}
