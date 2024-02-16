resource "aws_vpc" "project_vpc" {
    cidr_block = var.cidr 
    instance_tenancy = "default"
    enable_dns_hostnames = "true"
    enable_dns_support = "true"
    tags = {
        Name = "project_vpc"
    }
}

resource "aws_subnet" "pub_sub1" {
    vpc_id = aws_vpc.project_vpc.id
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "ap-south-1a"  
}

resource "aws_subnet" "pub_sub2" {
    vpc_id = aws_vpc.project_vpc.id
    cidr_block = "10.0.2.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "ap-south-1b"
}

resource "aws_subnet" "pub_sub3" {
    vpc_id = aws_vpc.project_vpc.id
    cidr_block = "10.0.3.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "ap-south-1c"
}

#so far so good
