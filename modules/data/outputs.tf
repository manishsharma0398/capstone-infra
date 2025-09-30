# modules/data/outputs.tf

output "data_vpc_id" {
  description = "ID of the Data VPC"
  value       = aws_vpc.main.id
}

output "data_private_subnet_ids" {
  description = "Private subnet IDs in Data VPC"
  value       = aws_subnet.private[*].id
}

output "data_private_route_table_ids" {
  description = "Private route table IDs in Data VPC"
  value       = aws_route_table.private[*].id
}
