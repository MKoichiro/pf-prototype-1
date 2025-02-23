output "cluster_arn" {
  value = aws_ecs_cluster.this.arn
}

output "namespace_arn" {
  value = aws_service_discovery_http_namespace.service_connect.arn
}

output "ecs_task_execution_role_arn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}

output "ecs_task_role_arn" {
  value = aws_iam_role.ecs_task_role.arn
}
