# modules\networking\outputs.tf

# ------------------------------
# VPC ID
# ------------------------------
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

# ------------------------------
# Public Subnets
# ------------------------------
output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

# ------------------------------
# Private Subnets
# ------------------------------
output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "private_subnet_cidrs" {
  description = "CIDR blocks of private subnets (for SG ingress rules)"
  value       = [for s in aws_subnet.private : s.cidr_block]
}

# ------------------------------
# Public Route Table (default RTB renamed)
# ------------------------------
output "public_route_table_id" {
  description = "ID of the public route table (renamed default RTB)"
  value       = aws_default_route_table.public.id
}

# ------------------------------
# Private Route Tables (one per private subnet)
# ------------------------------
output "private_route_table_ids" {
  description = "IDs of private route tables (one per private subnet)"
  value       = aws_route_table.private[*].id
}

# ------------------------------
# VPC Endpoint for S3
# ------------------------------
output "s3_vpc_endpoint_id" {
  description = "ID of the S3 VPC endpoint"
  value       = aws_vpc_endpoint.s3.id
}

# ------------------------------
# VPC Endpoint for Secrets Manager
# ------------------------------
output "secrets_manager_vpc_endpoint_id" {
  description = "ID of the Secrets Manager VPC Endpoint"
  value       = aws_vpc_endpoint.secrets_manager.id
}

output "secrets_manager_vpc_endpoint_sg_id" {
  description = "ID of the Secrets Manager SG"
  value       = aws_security_group.vpce_secrets.id
}

#  ADD DEBUG OUTPUTS

output "secrets_manager_vpc_endpoint_dns_entries" {
  description = "DNS entries for Secrets Manager VPC Endpoint"
  value       = aws_vpc_endpoint.secrets_manager.dns_entry
}

output "vpc_cidr_block" {
  description = "VPC CIDR block"
  value       = aws_vpc.main.cidr_block
}

output "vpc_dns_support" {
  description = "VPC DNS support status"
  value       = aws_vpc.main.enable_dns_support
}

output "vpc_dns_hostnames" {
  description = "VPC DNS hostnames status"
  value       = aws_vpc.main.enable_dns_hostnames
}
