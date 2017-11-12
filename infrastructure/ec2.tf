resource "aws_elb" "tsalisbury_cni_ec2_elb" {
  name               = "${var.ec2_elb_name}"
  availability_zones = ["${split(",", var.availability_zones)}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
    }

    health_check {
      healthy_threshold   = 2
      unhealthy_threshold = 2
      timeout             = 3
      target              = "HTTP:80/"
      interval            = 30
    }

    tags {
      Name = "${var.ec2_elb_name}"
    }
}

output "ec2_elb_dns_name" {
  value = "${aws_elb.tsalisbury_cni_ec2_elb.dns_name}"
}

resource "aws_elb" "tsalisbury_cni_ecs_elb" {
  name               = "${var.ecs_elb_name}"
  availability_zones = ["${split(",", var.availability_zones)}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
    }

    health_check {
      healthy_threshold   = 2
      unhealthy_threshold = 2
      timeout             = 3
      target              = "HTTP:8080/"
      interval            = 30
    }

    connection_draining = true

    tags {
      Name = "${var.ecs_elb_name}"
    }
}

resource "aws_launch_configuration" "tsalisbury_cni_launchconfig" {
  name                 = "tsalisbury_cni_launchconfig"
  key_name             = "${aws_key_pair.tsalisbury_key.key_name}"
  image_id             = "${var.ami_id}"
  instance_type        = "${var.instance_type}"
  iam_instance_profile = "${aws_iam_instance_profile.tsalisbury_cni_ec2_instance_profile.id}"
  security_groups      = ["${aws_security_group.tsalisbury-cni-ec2-sg.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.tsalisbury_cni_ec2_instance_profile.name}"
  user_data            = "#!/bin/bash\necho ECS_CLUSTER=${aws_ecs_cluster.tsalisbury_cni_cluster.name} > /etc/ecs/ecs.config"
}

resource "aws_autoscaling_group" "tsalisbury_cni_asg" {
  name                 = "tsalisbury-cni-asg"
  load_balancers       = ["tsalisbury-cni-ec2-elb"]
  availability_zones   = ["${split(",", var.availability_zones)}"]
  launch_configuration = "${aws_launch_configuration.tsalisbury_cni_launchconfig.name}"
  min_size             = 2
  max_size             = 2
  desired_capacity     = 2
}

resource "aws_key_pair" "tsalisbury_key" {
  key_name   = "tsalisbury_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDTFR6uAikimIWb43wvlTANuUN9QdvI1Jhy20K2dIJuq5UyG4hjFPMDqkeu6ZchYncikuPc3K+u/VAP80yihNCuNKjJ6zb7uxAOriELeFsVm+OFDxng7Me4XYNTB4rNzwRMxq4QhOkx06QGCYMshd2hIURqNqDhFY8pwM/sfshhKLzsFJcB3asuu78c9gvA+Iya8dvamygkZAqdULPIYuV1rzp7wCYi6Zbs+7t66BJ4uKDuNfoH8Rk1DXnNPFlX3y8w4LFvYpP5yboxupg4vnPMb+BTlgGbwM94Bfhp22+47TMKa639z+g+ZTkSwst7Zw1e9ds084D//iZx61baKi/f tom@toms-mbp.mynet"
}
