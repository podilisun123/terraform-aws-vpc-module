## vpc
resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge(
    var.common_tags,
    var.vpc_tags,
    {
        Name = local.resource_name
    }
  )
}
## igw
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.igw_tags,
    {
        Name = local.resource_name
    }
  )
  
}
# Public subnet
resource "aws_subnet" "public" {
  count = length(var.public_subnet_dirs)
  vpc_id     = aws_vpc.main.id
  availability_zone = local.zones_names[count.index]
  cidr_block = var.public_subnet_dirs[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.common_tags,
    var.public_subnet_tags,
    {
        Name = "${local.resource_name}-public-${local.zones_names[count.index]}"
    }
  )
}
## private subnet
resource "aws_subnet" "private" {
  count = length(var.private_subnet_dirs)
  vpc_id     = aws_vpc.main.id
  availability_zone = local.zones_names[count.index]
  cidr_block = var.private_subnet_dirs[count.index]
  
  tags = merge(
    var.common_tags,
    var.private_subnet_tags,
    {
        Name = "${local.resource_name}-private-${local.zones_names[count.index]}"
    }
  )
}
### database subnet
resource "aws_subnet" "database" {
  count = length(var.database_subnet_dirs)
  vpc_id     = aws_vpc.main.id
  availability_zone = local.zones_names[count.index]
  cidr_block = var.database_subnet_dirs[count.index]

  tags = merge(
    var.common_tags,
    var.database_subnet_tags,
    {
        Name = "${local.resource_name}-database-${local.zones_names[count.index]}"
    }
  )
}
### database subnet group
resource "aws_db_subnet_group" "database_group" {
  name       = local.resource_name
  subnet_ids = aws_subnet.database[*].id

  tags = merge(
    var.common_tags,
    var.database_subnet_group_tags,
    {
        Name = "${local.resource_name}"
    }
  )
}
### elastic ip
resource "aws_eip" "eip" {
  domain   = "vpc"
}
### NAT Gate way
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public[0].id

  tags =  merge(
    var.common_tags,
    var.ngw_tags,
    {
        Name = "${local.resource_name}"
    }
  )
  depends_on = [aws_internet_gateway.igw]
}
### public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.public_route_table_tags,
    {
        Name = "${local.resource_name}-public"
    }
  )
}
### private route table

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.private_route_table_tags,
    {
        Name = "${local.resource_name}-private"
    }
  )
}

### database route table

resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.database_route_table_tags,
    {
        Name = "${local.resource_name}-database"
    }
  )
}
resource "aws_route" "public_route" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}
resource "aws_route" "private_nat" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat.id
}
resource "aws_route" "database_nat" {
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat.id
}
resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_dirs)
  subnet_id      = element(aws_subnet.public[*].id,count.index)
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_dirs)
  subnet_id      = element(aws_subnet.private[*].id,count.index)
  route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "database" {
  count = length(var.database_subnet_dirs)
  subnet_id      = element(aws_subnet.database[*].id,count.index)
  route_table_id = aws_route_table.database.id
}