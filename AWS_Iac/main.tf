resource "aws_instance" "sample_instance" {
    ami = "ami-0449c34f967dbf18a"
    availability_zone = "ap-south-1a"
    subnet_id = aws_subnet.pvt_sub1.id
    instance_type = "t2.micro"
  
}