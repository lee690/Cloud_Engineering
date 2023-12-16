# Configure the VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main-vpc"
  }
}

# Create subnets
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-west-2b"

  tags = {
    Name = "private-subnet"
  }
}

# Internet Gateway and attachment
resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

resource "aws_vpc_attachment" "attach_gateway" {
  vpc_id = aws_vpc.main.id
  internet_gateway_id = aws_internet_gateway.gateway.id

  tags = {
    Name = "main-igw-attachment"
  }
}

# Route tables and routes
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route" "public_route" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.gateway.id

  tags = {
    Name = "public-route-to-igw"
  }
}

# Configure NAT Gateway if needed for private subnet
resource "aws_nat_gateway" "nat_gateway" {
  subnet_id = aws_subnet.private.id

  tags = {
    Name = "private-nat-gateway"
  }
}

# Route private subnet traffic to NAT Gateway
resource "aws_route" "private_route_to_nat" {
  route_table_id = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_nat_gateway.nat_gateway.id

  tags = {
    Name = "private-route-to-nat"
  }

}

# Security groups for EC2 instances
resource "aws_security_group" "instance_a_sg" {
  name = "instance-a-sg"
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "instance-a-sg"
  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "instance_b_sg" {
  name = "instance-b-sg"
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "instance-b-sg"
  }
}

  ingress {
    from_port = 0
    to_port = 0
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
  }