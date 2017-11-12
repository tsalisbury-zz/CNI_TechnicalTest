variable "region" {
  default = "eu-west-1"
}

variable "ami_id" {
  default = "ami-d65dfbaf"
}

variable "ecs_cluster_name" {
  default = "tsalisbury_cni_cluster"
}

variable "ecs_elb_name" {
  default = "tsalisbury-cni-ecs-elb"
}

variable "ec2_elb_name" {
  default = "tsalisbury-cni-ec2-elb"
}

variable "elb_security_group" {
  default = "tsalisbury-cni-elb-sg"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "ec2_security_group" {
  default = "tsalisbury-cni-ec2-sg"
}

variable "availability_zones" {
  description = "The availability zones"
  default = "eu-west-1a,eu-west-1b,eu-west-1c"
}
