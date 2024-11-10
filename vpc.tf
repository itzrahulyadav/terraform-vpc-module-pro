locals {
    public_subnets = {
        for key,config in var.subnet_config: key => config if config.public
    }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "pro" {
  cidr_block = var.vpc_config.cidr_block

  tags = {
    Name = var.vpc_config.name
  }
}

resource "aws_subnet" "pro_subnet" {
  for_each          = var.subnet_config
  vpc_id            = aws_vpc.pro.id
  availability_zone = each.value.az
  cidr_block        = each.value.cidr_block

  tags = {
    Name = each.key
  }

  lifecycle {
    precondition {
      condition     = contains(data.aws_availability_zones.available.names, each.value.az)
      error_message = "Invalid AZ for the region"
    }
  }

}

resource "aws_internet_gateway" "igw" {
    count = length(local.public_subnets) > 0 ? 1 : 0
    vpc_id = aws_vpc.pro.id

}

resource "aws_route_table" "public_rtb" {
    count = length(local.public_subnets) > 0 ? 1 : 0
    vpc_id = aws_vpc.pro.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw[0].id
    }
}

resource "aws_route_table_association" "public" {
     for_each = local.public_subnets
     subnet_id = aws_subnet.pro_subnet[each.key].id
     route_table_id = aws_route_table.public_rtb[0].id
}