resource "aws_vpc" "Devops_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "vpc_001"
  }
}
 
 # create public subnet-1

resource "aws_subnet" "pubilc-subnet_01" {
  vpc_id     = aws_vpc.Devops_vpc.id
  cidr_block = "10.0.1.0/24"
 availability_zone = "us-east-1"

  tags = {
    Name = "My-pubilc-subnet_1a"
  }
}

# create public subnet-2
resource "aws_subnet" "pubilc-subnet_2" {
  vpc_id     = aws_vpc.Devops_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "My-pubilc-subnet_2"
  }
}
 # create ptivate subnet
resource "aws_subnet" "private-subnet_1" {
  vpc_id     = aws_vpc.Devops_vpc.id
  cidr_block = "10.0.3.0/24"
availability_zone = "us-east-1b"
  tags = {
    Name = "My-privatesubnet-subnet_1"
  }
}

# create internet gateway

resource "aws_internet_gateway" "Internetgateway" {
  vpc_id = aws_vpc.Devops_vpc.id

  tags = {
    Name = "Internetgateway-001"
  }
}

# create public-route table
resource "aws_route_table" "pubilc-routetable" {
  vpc_id = aws_vpc.Devops_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Internetgateway.id
  }

  

  tags = {
    Name = "Devops-routetable"
  }
}

# subnet association subnet-001
resource "aws_route_table_association" "public-subnet-asso-1" {
  subnet_id      = aws_subnet.pubilc-subnet_1.id
  route_table_id = aws_route_table.pubilc-routetable.id
}

# subnet association subnet-002

resource "aws_route_table_association" "public-subnet-asso-2" {
  subnet_id      = aws_subnet.pubilc-subnet_2.id
  route_table_id = aws_route_table.pubilc-routetable.id
}

# creating elastic ip

resource "aws_eip" "MyElastic-ip" {
  domain   = "vpc"
}


# nat gateway
resource "aws_nat_gateway" "Devops-natgateway" {
  allocation_id = aws_eip.MyElastic-ip.id
  subnet_id     = aws_subnet.pubilc-subnet_1.id

  tags = {
    Name = "Devops-nategateway"
  }
}

#private route table
resource "aws_route_table" "private-routetable" {
  vpc_id = aws_vpc.Devops_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.Devops-natgateway.id
  }

  

  tags = {
    Name = "Devops-private-routetable"
  }
}

# create associate private subnet
resource "aws_route_table_association" "private-subnet_1" {
  subnet_id      = aws_subnet.private-subnet_1.id
  route_table_id = aws_route_table.private-routetable.id
}

# create security group


resource "aws_security_group" "Public-security-group" {
  vpc_id      = Devops_vpc

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Public-security-group"
  }
}
# to create private securitygroup

resource "aws_security_group" "Private-security-group" {
  vpc_id = Devops_vpc
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Private-security-group"
  }
}

# instance creation

resource "aws_instance" "Publicinstance1" {
  ami           = ami-06b21ccaeff8cd686
  instance_type = t2.micro
  subnet_id     = pubilc-subnet_1
  vpc_security_group_ids = [Public-security-group]
   tags = {
    Name = "Public-instance-001"
  }
}


resource "aws_instance" "Publicinstance2" {
  ami           = ami-06b21ccaeff8cd686
  instance_type = t2.micro
  subnet_id     = pubilc-subnet_2
  vpc_security_group_ids = [Public-security-group]
   tags = {
    Name = "Public-instance-002"
  }
}



#PRIVATE instance creation
resource "aws_instance" "Privateinstance2" {
  ami           = ami-06b21ccaeff8cd686
  instance_type = t2.micro
  subnet_id     = private-subnet_1
  vpc_security_group_ids = [Private-security-group]
   tags = {
    Name = "Private-instance-001"
  }
}
