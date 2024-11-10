output "public_subnet" {
     value = local.public_subnets
     description = "The id and az of created subnet"
}

output "vpc_id" {
    description = "The aws id of the created vpc"
    value = aws_vpc.pro.id
  
}