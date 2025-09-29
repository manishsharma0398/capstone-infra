# resource "aws_vpc" "main" {
#   cidr_block           = var.cidr_block
#   instance_tenancy     = "default"
#   enable_dns_support   = true
#   enable_dns_hostnames = true

#   tags = {
#     Name = "main"
#   }
# }

# resource "aws_subnet" "public" {
#   count             = length(var.public_subnets)
#   vpc_id            = aws_vpc.main.id
#   cidr_block        = var.public_subnets[count.index]
#   availability_zone = var.azs[count.index]
# }

# resource "aws_subnet" "private" {
#   count             = length(var.private_subnets)
#   vpc_id            = aws_vpc.main.id
#   cidr_block        = var.private_subnets[count.index]
#   availability_zone = var.azs[count.index]
# }
