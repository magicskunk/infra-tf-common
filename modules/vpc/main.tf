# https://medium.com/devops-mojo/terraform-provision-amazon-eks-cluster-using-terraform-deploy-create-aws-eks-kubernetes-cluster-tf-4134ab22c594
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {

  cidr_block           = var.vpc_cidr
  # Determines whether the VPC supports assigning public DNS hostnames to instances with public IP addresses.
  # The default for this attribute is false unless the VPC is a default VPC.
  enable_dns_hostnames = true
  # Determines whether the VPC supports DNS resolution through the Amazon provided DNS server.
  # If this attribute is true, queries to the Amazon provided DNS server succeed. For more information, see Amazon DNS server.
  # The default for this attribute is true.
  enable_dns_support   = true

  tags = merge(var.tags, {
    Name = "${var.env_code}_${var.organization_name}_vpc"
  })
}

# Public Subnets
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidr)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidr[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index % var.availability_zones_count]

  # makes it public
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "${var.env_code}_${var.organization_name}_public${count.index}"
  })
}


# Private Subnets
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidr)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index % var.availability_zones_count]

  tags = merge(var.tags, {
    Name = "${var.env_code}_${var.organization_name}_private${count.index}"
  })
}

# Create Internet Gateway to provide internet access for services within VPC.
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = merge(var.tags, {
    Name = "${var.env_code}_${var.organization_name}_ig"
  })
}

# Create NAT Gateway in public subnet. It is used in private subnets to allow services to connect to the internet.
resource "aws_eip" "nat_gateway_ip" {
  vpc = true

  tags = merge(var.tags, {
    Name = "${var.env_code}_${var.organization_name}_ng_ip"
  })
}

resource "aws_nat_gateway" "main" {
  # elastic ip, always reachable
  allocation_id = aws_eip.nat_gateway_ip.id
  subnet_id     = aws_subnet.public[0].id

  depends_on = [aws_internet_gateway.main]

  tags = merge(var.tags, {
    Name = "${var.env_code}_${var.organization_name}_ng"
  })
}

# Routes. Public route table routes traffic through igw. Private route table routes traffic through NAT gw
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  # route to igw for internet access
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  depends_on = [aws_internet_gateway.main]

  tags = merge(var.tags, {
    Name = "${var.env_code}_${var.organization_name}_public_rt"
  })
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidr)

  route_table_id = aws_route_table.public.id
  subnet_id      = element(aws_subnet.public.*.id, count.index)

  depends_on = [aws_subnet.public]
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  depends_on = [aws_nat_gateway.main]

  tags = merge(var.tags, {
    Name = "${var.env_code}_${var.organization_name}_private_rt"
  })
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidr)

  route_table_id = aws_route_table.private.id
  subnet_id      = element(aws_subnet.private.*.id, count.index)

  depends_on = [aws_subnet.private]
}
