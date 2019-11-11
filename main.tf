# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
}

# Create a VPC to launch our instances into
resource "aws_vpc" "default" {
  cidr_block = "${var.aws_vpc_cidr}"
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

# Define external subnets for the security layer facing internet in availability zones
resource "aws_subnet" "inbound_external_subnet" {
  count             = 2
  availability_zone = "${data.aws_availability_zones.azs.names[count.index]}"
  vpc_id            = "${aws_vpc.default.id}"
  cidr_block        = "${cidrsubnet(var.aws_vpc_cidr, 8, count.index+100 )}"
  
  tags {
    Name = "Inbound-External-${count.index+1}"
  }
}

# Define a subnet for the web servers in the primary availability zone
resource "aws_subnet" "inbound_internal_subnet" {
  count             = 2
  availability_zone = "${data.aws_availability_zones.azs.names[count.index]}"
  vpc_id            = "${aws_vpc.default.id}"
  cidr_block        = "${cidrsubnet(var.aws_vpc_cidr, 8, count.index+200 )}"
  
  tags {
    Name = "Inbound-Internal-${count.index+1}"
  }
}

# A security group for the ELB so it is accessible via the web
resource "aws_security_group" "elb" {
  name        = "terraform_example_elb"
  description = "Used in the terraform"
  vpc_id      = "${aws_vpc.default.id}"

  # Open access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

# outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "permissive" {
  name        = "terraform_permissive_sg"
  description = "Used in the terraform"
  vpc_id      = "${aws_vpc.default.id}"


  # access from the internet
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_launch_configuration" "sgw_conf" {
  name          = "sgw_config"
  image_id      = "${data.aws_ami.chkp_ami.id}"
  instance_type = "${var.cg_size}" 
  key_name      = "${aws_key_pair.auth.id}"
  security_groups = ["${aws_security_group.permissive.id}"]
  user_data     = "${var.my_user_data}"
  associate_public_ip_address = true
}
resource "aws_launch_configuration" "web_conf" {
  name          = "web_config"
  image_id      = "${data.aws_ami.ubuntu_ami.id}"
  instance_type = "${var.ws_size}"
  key_name      = "${aws_key_pair.auth.id}"
  security_groups = ["${aws_security_group.permissive.id}"]
  user_data     = "${var.ubuntu_user_data}"
  associate_public_ip_address = true
}
resource "aws_elb" "sgw" {
  name = "terraform-external-elb"

  subnets         = ["${aws_subnet.inbound_external_subnet.*.id}"]
  security_groups = ["${aws_security_group.permissive.id}"]

  listener {
    instance_port     = 8090
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8090/"
    interval            = 5
  }
}

resource "aws_autoscaling_group" "sgw_asg" {
  name = "cg-layer-autoscale"
  launch_configuration = "${aws_launch_configuration.sgw_conf.id}"
  max_size = 4
  min_size = 2
  load_balancers = ["${aws_elb.sgw.id}"]
  vpc_zone_identifier = ["${aws_subnet.inbound_external_subnet.*.id}"]

  tag {
      key = "Name"
      value = "CHKP-AutoScale"
      propagate_at_launch = true
  }
  tag {
      key = "x-chkp-tags"
      value = "management=${var.management_server_name}:template=${var.template_name}"
      propagate_at_launch = true
  }


}

resource "aws_autoscaling_group" "web_asg" {
  name = "web-layer-autoscale"
  launch_configuration = "${aws_launch_configuration.web_conf.id}"
  max_size = 4
  min_size = 2
  health_check_grace_period = 5
  load_balancers = ["${aws_elb.web.id}"]
  vpc_zone_identifier = ["${aws_subnet.inbound_internal_subnet.*.id}"]
  tag {
      key = "Name"
      value = "web-AutoScale"
      propagate_at_launch = true
  }
  tag {
      key = "data-profile"
      value = "PCI"
      propagate_at_launch = true
  }
}
resource "aws_elb" "web" {
  name = "terraform-web-elb"

  subnets         = ["${aws_subnet.inbound_internal_subnet.*.id}"]
  security_groups = ["${aws_security_group.permissive.id}"]
  tags {
    x-chkp-tags = "management=${var.management_server_name}:template=${var.template_name}"
  }            

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 8090
    lb_protocol       = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:80"
    interval            = 5
  }
}

resource "aws_key_pair" "auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

output "ext_lb_dns" {
  value = "${aws_elb.sgw.dns_name}"
}
