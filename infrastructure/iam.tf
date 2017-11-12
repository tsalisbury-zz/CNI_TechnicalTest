resource "aws_iam_role" "tsalisbury_cni_ec2_role" {
    name = "tsalisbury_cni_ec2_role"

    lifecycle {
      create_before_destroy = true
    }

    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "ec2.amazonaws.com"
          ]
        },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "tsalisbury_cni_ec2_policy" {
    name        = "tsalisbury_cni_ec2_policy"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:CreateCluster",
        "ecs:DeregisterContainerInstance",
        "ecs:DiscoverPollEndpoint",
        "ecs:Poll",
        "ecs:RegisterContainerInstance",
        "ecs:StartTelemetrySession",
        "ecs:UpdateContainerInstancesState",
        "ecs:Submit*",
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
        ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "tsalisbury-ec2-attach" {
    role       = "${aws_iam_role.tsalisbury_cni_ec2_role.name}"
    policy_arn = "${aws_iam_policy.tsalisbury_cni_ec2_policy.arn}"
}

resource "aws_iam_instance_profile" "tsalisbury_cni_ec2_instance_profile" {
  name = "tsalisbury-cni-ec2-instance-profile"
  path = "/"
  role = "${aws_iam_role.tsalisbury_cni_ec2_role.name}"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "tsalisbury_cni_ecs_role" {
    name = "tsalisbury_cni_ecs_role"

    lifecycle {
      create_before_destroy = true
    }

    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "ecs.amazonaws.com"
          ]
        },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "tsalisbury_cni_ecs_policy" {
    name        = "tsalisbury_cni_ecs_policy"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:Describe*",
        "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
        "elasticloadbalancing:DeregisterTargets",
        "elasticloadbalancing:Describe*",
        "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
        "elasticloadbalancing:RegisterTargets"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "tsalisbury-ecs-attach" {
    role       = "${aws_iam_role.tsalisbury_cni_ecs_role.name}"
    policy_arn = "${aws_iam_policy.tsalisbury_cni_ecs_policy.arn}"
}
