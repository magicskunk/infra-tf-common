locals {
  tags                = {}
  vpc_cidr            = "10.1.0.0/16"
  public_subnet_cidr  = ["10.1.0.0/20", "10.1.16.0/20", "10.1.32.0/20"]
  private_subnet_cidr = []
  public_subnet_tags  = {
    "kubernetes.io/role/elb"                      = "1"
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
  }
  deployment_flag = {
    vpc     = contains(lookup(var.deployment_flag, "vpc"), var.env_code)
    vpc_nat = contains(lookup(var.deployment_flag, "vpc_nat"), var.env_code)
  }
}

# https://medium.com/devops-mojo/terraform-provision-amazon-eks-cluster-using-terraform-deploy-create-aws-eks-kubernetes-cluster-tf-4134ab22c594
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  count = local.deployment_flag.vpc ? 1 : 0

  cidr_block           = local.vpc_cidr
  # Determines whether the VPC supports assigning public DNS hostnames to instances with public IP addresses.
  # The default for this attribute is false unless the VPC is a default VPC.
  enable_dns_hostnames = true
  # Determines whether the VPC supports DNS resolution through the Amazon provided DNS server.
  # If this attribute is true, queries to the Amazon provided DNS server succeed. For more information, see Amazon DNS server.
  # The default for this attribute is true.
  enable_dns_support   = true

  tags = merge(local.tags, {
    Name = "${var.env_code}_${var.organization_name}_vpc"
  })
}

# Public Subnets
resource "aws_subnet" "public" {
  count = local.deployment_flag.vpc ? length(local.public_subnet_cidr) : 0

  vpc_id            = aws_vpc.main[0].id
  cidr_block        = local.public_subnet_cidr[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index % var.aws_az_count]

  map_public_ip_on_launch = true

  tags = merge(local.tags, {
    Name = "${var.env_code}_${var.organization_name}_public${count.index}"
  })
}


# Private Subnets
resource "aws_subnet" "private" {
  count = local.deployment_flag.vpc ? length(local.private_subnet_cidr) : 0

  vpc_id            = aws_vpc.main[0].id
  cidr_block        = local.private_subnet_cidr[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index % var.aws_az_count]

  tags = merge(local.tags, local.public_subnet_tags, {
    Name = "${var.env_code}_${var.organization_name}_private${count.index}"
  })
}

# Create Internet Gateway to provide internet access for services within VPC.
resource "aws_internet_gateway" "main" {
  count = local.deployment_flag.vpc ? 1 : 0

  vpc_id = aws_vpc.main[0].id
  tags   = merge(local.tags, {
    Name = "${var.env_code}_${var.organization_name}_ig"
  })
}

# Create NAT Gateway in public subnet. It is used in private subnets to allow services to connect to the internet.
resource "aws_eip" "nat_gateway_ip" {
  count = local.deployment_flag.vpc_nat ? 1 : 0

  vpc = true

  tags = merge(local.tags, {
    Name = "${var.env_code}_${var.organization_name}_ng_ip"
  })
}

resource "aws_nat_gateway" "main" {
  count = local.deployment_flag.vpc_nat ? 1 : 0

  # elastic ip, always reachable
  allocation_id = aws_eip.nat_gateway_ip[count.index].id
  subnet_id     = aws_subnet.public[0].id

  depends_on = [aws_internet_gateway.main]

  tags = merge(local.tags, {
    Name = "${var.env_code}_${var.organization_name}_ng"
  })
}

# Routes. Public route table routes traffic through igw. Private route table routes traffic through NAT gw
resource "aws_route_table" "public" {
  count = local.deployment_flag.vpc ? 1 : 0

  vpc_id = aws_vpc.main[0].id

  # route to igw for internet access (this makes associated subnet public)
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main[0].id
  }

  depends_on = [aws_internet_gateway.main]

  tags = merge(local.tags, {
    Name = "${var.env_code}_${var.organization_name}_public_rt"
  })
}

resource "aws_route_table_association" "public" {
  count = local.deployment_flag.vpc ? length(local.public_subnet_cidr) : 0

  route_table_id = aws_route_table.public[0].id
  subnet_id      = element(aws_subnet.public[*].id, count.index)

  depends_on = [aws_subnet.public]
}

resource "aws_route_table" "private" {
  count = local.deployment_flag.vpc_nat ? 1 : 0

  vpc_id = aws_vpc.main[0].id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[0].id
  }

  depends_on = [aws_nat_gateway.main]

  tags = merge(local.tags, {
    Name = "${var.env_code}_${var.organization_name}_private_rt"
  })
}

resource "aws_route_table_association" "private" {
  count = local.deployment_flag.vpc_nat ? length(local.private_subnet_cidr) : 0

  route_table_id = aws_route_table.private[0].id
  subnet_id      = element(aws_subnet.private[*].id, count.index)

  depends_on = [aws_subnet.private]
}
