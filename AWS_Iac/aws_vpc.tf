resource "aws_vpc" "project_vpc" {
    cidr_block = var.cidr 
    instance_tenancy = "default"
    enable_dns_hostnames = "true"
    enable_dns_support = "true"
    tags = {
        Name = "project_vpc"
    }
}

# public subnet 1 in ap-south-1a
resource "aws_subnet" "pub_sub1" {
    vpc_id = aws_vpc.project_vpc.id
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "ap-south-1a"  
}

# public subnet 2 in ap-south-1b
resource "aws_subnet" "pub_sub2" {
    vpc_id = aws_vpc.project_vpc.id
    cidr_block = "10.0.2.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "ap-south-1b"
}

#public subnet 3 in ap-south-1c
resource "aws_subnet" "pub_sub3" {
    vpc_id = aws_vpc.project_vpc.id
    cidr_block = "10.0.3.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "ap-south-1c"
}

#Private subnet 1 in ap-sputh-1a
resource "aws_subnet" "pvt_sub1" {
    vpc_id = aws_vpc.project_vpc.id
    cidr_block = "10.0.4.0/24"
    map_public_ip_on_launch = "false"
    availability_zone = "ap-south-1a"
  
}

#Private subnet 1 in ap-sputh-1a
resource "aws_subnet" "pvt_sub2" {
    vpc_id = aws_vpc.project_vpc.id
    cidr_block = "10.0.5.0/24"
    map_public_ip_on_launch = "false"
    availability_zone = "ap-south-1b"
  
}

#Private subnet 1 in ap-sputh-1a
resource "aws_subnet" "pvt_sub2" {
    vpc_id = aws_vpc.project_vpc.id
    cidr_block = "10.0.6.0/24"
    map_public_ip_on_launch = "false"
    availability_zone = "ap-south-1c"
  
}

# Internet Gateway
resource "aws_internet_gateway" "IGW_VPC" {
    vpc_id = aws_vpc.project_vpc.id

}

#Route table for public subnets
resource "aws_route_table" "PubSub_RT" {
    vpc_id = aws_vpc.project_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.IGW_VPC.id
    }
}

#Associating route table with public subnets
resource "aws_route_table_association" "pub_sub1_associsation" {
    subnet_id = aws_subnet.pub_sub1.id
    route_table_id = aws_route_table.PubSub_RT.id
}

resource "aws_route_table_association" "pub_sub2_associsation" {
    subnet_id = aws_subnet.pub_sub2.id
    route_table_id = aws_route_table.PubSub_RT.id
}

resource "aws_route_table_association" "pub_sub3_associsation" {
    subnet_id = aws_subnet.pub_sub3.id
    route_table_id = aws_route_table.PubSub_RT.id
}

#Elastic IP for NAT Gateway
resource "aws_eip" "NAT_EIP" {
    vpc = true  
}

#NAT Gateway
resource "aws_nat_gateway" "NAT_Gateway" {
    allocation_id = aws_eip.NAT_EIP.id
    subnet_id = aws_subnet.pub_sub1.id
    depends_on = [ aws_internet_gateway.IGW_VPC.id ]
  
}

#Route table for NAT
resource "aws_route_table" "PrivateRT" {
    vpc_id = aws_vpc.project_vpc.id
    route {
        cidr_block = "0.0.0.0/16"
        nat_gateway_id = aws_nat_gateway.NAT_Gateway.id
    }
  
}

#Associate private route table to private subnets
resource "aws_route_table_association" "pvt_sub1_association" {
    subnet_id = aws_subnet.pvt_sub1.id
    route_table_id = aws_route_table.PrivateRT.id
  
}

resource "aws_route_table_association" "pvt_sub2_association" {
    subnet_id = aws_subnet.pvt_sub1.id
    route_table_id = aws_route_table.PrivateRT.id
  
}

resource "aws_route_table_association" "pvt_sub2_association" {
    subnet_id = aws_subnet.pvt_sub1.id
    route_table_id = aws_route_table.PrivateRT.id
  
}