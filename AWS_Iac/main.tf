# Security group for instances 
resource "aws_security_group" "Instance_SG" {
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 22
        to_port = 22
        protocol = "ssh"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
}

resource "aws_security_group" "Loadbalancer_SG" {
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
}

#key pairs
resource "aws_key_pair" "keys" {
    key_name = "project_key"
    public_key = file("~/.ssh/id_rsa.pub")
  
}



# Launch Template
resource "aws_launch_template" "ec2_template" {
    instance_type = "t2.micro"
    image_id = "ami-0e731c8a588258d0d"
    vpc_security_group_ids  = [ aws_security_group.Instance_SG.id ]
    key_name = aws_key_pair.keys.key_name
}

#Load balancer

#Target groups

#Load balancer listener

#Load balancer listener rule

#Auto scaling group

#route53 zone creation
