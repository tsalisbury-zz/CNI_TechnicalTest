resource "aws_ecs_cluster" "tsalisbury_cni_cluster" {
  name = "${var.ecs_cluster_name}"
}

resource "aws_ecs_service" "tsalisbury_cni_service" {
  name                                = "tsalisbury_cni_service"
  cluster                             = "${aws_ecs_cluster.tsalisbury_cni_cluster.id}"
  task_definition                     = "${aws_ecs_task_definition.tsalisbury_cni_task_def.arn}"
  desired_count                       = 2
  deployment_minimum_healthy_percent  = 50
  deployment_maximum_percent          = 200
  iam_role                            = "${aws_iam_role.tsalisbury_cni_ecs_role.arn}"

  load_balancer {
    elb_name       = "tsalisbury-cni-ecs-elb"
    container_name = "tsalisbury_cni_app"
    container_port = 8080
  }
}

resource "aws_ecs_task_definition" "tsalisbury_cni_task_def" {
  family                = "tsalisbury_cni"
  container_definitions = "${file("task-definitions/tsalisbury_cni_app.json")}"
}
