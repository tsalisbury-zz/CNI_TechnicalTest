resource "aws_ecr_repository" "tsalisbury_cni_app" {
  name = "tsalisbury_cni_app"
}

output "cni_repository_url" {
  value = "${aws_ecr_repository.tsalisbury_cni_app.repository_url}"
}
