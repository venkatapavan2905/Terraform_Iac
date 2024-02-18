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
    name = "ec2_template"
    instance_type = "t2.micro"
    image_id = "ami-0e731c8a588258d0d"
    vpc_security_group_ids  = [ aws_security_group.Instance_SG.id ]
    key_name = aws_key_pair.keys.key_name
    user_data = filebase64("${path.module}/websetup.sh")
}

#Load balancer
resource "aws_lb" "LoadBalancer_ALB" {
    load_balancer_type = "application"
    subnets = [aws_subnet.pub_sub1.id]
    security_groups = [aws_security_group.Loadbalancer_SG.id]
}

#Target groups
resource "aws_lb_target_group" "Target_Instances" {
    name = "Target-Instances"
    port = 80
    protocol = "HTTP"
    vpc_id   = aws_vpc.project_vpc.id
    health_check {
        path                = "/"
        protocol            = "HTTP"
        matcher             = "200"
        interval            = 15
        timeout             = 3
        healthy_threshold   = 2
        unhealthy_threshold = 2
    }
}

#Load balancer listener rule
resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100
  condition {
    path_pattern {
      values = ["*"]
    }
  }
  action {
   type            ="forward"
   target_group_arn=aws_lb_target_group.Target_Instances.arn
  }
}

#Load balancer listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.LoadBalancer_ALB.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

#Auto scaling group
resource "aws_autoscaling_group" "demo" {
  launch_template {
    id = aws_launch_template.ec2_template.id
  }
  vpc_zone_identifier = [aws_subnet.pvt_sub1.id, aws_subnet.pvt_sub2.id, aws_subnet.pvt_sub3.id]
  target_group_arns = [aws_lb_target_group.Target_Instances.arn]
  #health_check_type = "ELB"
  min_size = 1
  max_size = 2
  tag {
    key                 = "demo"
    value               = "webserver-with-asg-lb"
    propagate_at_launch = true
  }
}

#route53 zone creation
resource "aws_route53_zone" "dns_zone" {
  name = "yvpinfo.xyz"
}

#route53 record creation
resource "aws_route53_record" "ns_record" {
  zone_id = aws_route53_zone.dns_zone.id
  name    = "terraiacproj.yvpinfo.xyz"
  type    = "A"
  ttl     = 300
  records = [aws_lb.LoadBalancer_ALB.dns_name]
  
}

output "load-balancer-dns-name" {
  value = aws_lb.LoadBalancer_ALB.dns_name
  description = "FQDN of alb"
}
