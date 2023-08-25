provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public" {
  count             = 1
  cidr_block       = "10.0.${count.index}.0/24"
  vpc_id           = aws_vpc.main.id
  availability_zone = "ap-south-1a"  
}

resource "aws_subnet" "private" {
  count             = 2
  cidr_block       = "10.0.${count.index + 10}.0/24"
  vpc_id           = aws_vpc.main.id
  availability_zone = "ap-south-1b"  
}

resource "aws_security_group" "public_sg" {
  name        = "public-sg"
  description = "Security group for public instances"
  vpc_id      = aws_vpc.main.id
}

resource "aws_security_group" "private_sg" {
  name        = "private-sg"
  description = "Security group for private instances"
  vpc_id      = aws_vpc.main.id
}

resource "aws_instance" "public_instance" {
  ami           = "ami-0da59f1af71ea4ad2"  # Specify a valid AMI ID
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.public_sg.id]
}

resource "aws_eip" "public_instance_eip" {
  instance = aws_instance.public_instance.id
}

resource "aws_instance" "private_instance1" {
  ami           = "ami-0da59f1af71ea4ad2"  # Specify a valid AMI ID
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private[0].id
  vpc_security_group_ids = [aws_security_group.private_sg.id]
}

resource "aws_instance" "private_instance2" {
  ami           = "ami-0da59f1af71ea4ad2"  # Specify a valid AMI ID
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private[1].id
  vpc_security_group_ids = [aws_security_group.private_sg.id]
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table_association" "public_rta" {
  count          = 1
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_rta" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_rt.id
}
