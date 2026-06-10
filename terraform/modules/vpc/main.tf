locals {
  public_subnets = {
    for idx, cidr in var.public_subnet_cidrs :
    idx => cidr
  }
  private_subnets = {
    for idx, cidr in var.private_subnet_cidrs :
    idx => cidr
  }
  database_subnets = {
    for idx, cidr in var.database_subnet_cidrs :
    idx => cidr
  }
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(var.default_tags, {
    Name = "${var.label}-vpc"
  })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.default_tags, {
    Name = "${var.label}-igw"
  })
}

resource "aws_subnet" "public" {
  for_each          = local.public_subnets
  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  availability_zone = var.availability_zones[tonumber(each.key)]

  tags = merge(var.default_tags, {
    Name = "${var.label}-public-subnet-${each.key}"
  })
}

resource "aws_subnet" "private" {
  for_each          = local.private_subnets
  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  availability_zone = var.availability_zones[tonumber(each.key)]

  tags = merge(var.default_tags, {
    Name = "${var.label}-private-subnet-${each.key}"
  })
}

resource "aws_subnet" "database" {
  for_each          = local.database_subnets
  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  availability_zone = var.availability_zones[tonumber(each.key)]

  tags = merge(var.default_tags, {
    Name = "${var.label}-database-subnet-${each.key}"
  })
}

resource "aws_eip" "nat" {
  for_each = aws_subnet.public
  domain   = "vpc"
}

# one NAT GW per public subnet (one per AZ)
resource "aws_nat_gateway" "nat_gw" {
  for_each      = aws_subnet.public
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = each.value.id

  tags = merge(var.default_tags, {
    Name = "${var.label}-nat-gw-${each.key}"
  })
}

# 
# single route table pointing to the internet gateway for both public subnet
#
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.default_tags, {
    Name = "${var.label}-public-rt"
  })
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_rt.id
}

# 
# two private routes for respective NAT per az
#
resource "aws_route_table" "private_rt" {
  for_each = aws_subnet.private
  vpc_id   = aws_vpc.this.id

  tags = merge(var.default_tags, {
    Name = "${var.label}-private-rt-${each.key}"
  })
}

resource "aws_route" "private_nat" {
  for_each               = aws_route_table.private_rt
  route_table_id         = aws_route_table.private_rt[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw[each.key].id
}

resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_rt[each.key].id
}

#
# database route table only contain local routes, no internet access
#
resource "aws_route_table" "database_rt" {
  for_each = aws_subnet.database
  vpc_id   = aws_vpc.this.id

  tags = merge(var.default_tags, {
    Name = "${var.label}-database-rt-${each.key}"
  })
}

resource "aws_route_table_association" "database_rt" {
  for_each       = aws_subnet.database
  subnet_id      = each.value.id
  route_table_id = aws_route_table.database_rt[each.key].id
}
