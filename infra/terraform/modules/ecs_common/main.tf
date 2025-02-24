# Links to official documentation:
# * Resource: aws_ecs_cluster                       [https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster]
# * Resource: aws_service_discovery_http_namespace  [https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_http_namespace]
# * Resource: aws_iam_role                          [https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role]
# * Resource: aws_iam_role_policy_attachment        [https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment]
# * Resource: aws_iam_role_policy                   [https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy]

# Cluster
resource "aws_ecs_cluster" "this" {
  name = "${var.env_prefix}-pf-cluster"
}

# CloudMap namespace
resource "aws_service_discovery_http_namespace" "service_connect" {
  name = aws_ecs_cluster.this.name
}

# Role
# Create ecsTaskExecutionRole
# Generate inline AssumeRole Policy (Trust Policy for the Role)
data "aws_iam_policy_document" "trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# Complement the AWS managed Permission Policy by followings
data "aws_iam_policy_document" "additional_permission_policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "ssm:GetParameters",
      "secretsmanager:GetSecretValue",
      "kms:Decrypt"
    ]
    resources = ["*"]
  }
}
# task role
data "aws_iam_policy_document" "ecs_task_role" {
  statement {
    effect = "Allow"
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
    resources = ["*"]
  }
}

# Create IAM Role with the Trust Policy
#   In the specification, Permission policies must be attached separately from this block.
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.env_prefix}-ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.trust_policy.json
}
# task role
resource "aws_iam_role" "ecs_task_role" {
  name               = "${var.env_prefix}-ecsTaskRole"
  assume_role_policy = data.aws_iam_policy_document.trust_policy.json
}

# Attach the AWS managed Permission Policy to the Role
#   This resource only supports attachment of AWS managed policies.
resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Attach the additional permission policy to the Role
#   This resource only supports direct attachment of inline policies.
resource "aws_iam_role_policy" "ecs_task_execution_role" {
  name       = "additional_permission_policy"
  role       = aws_iam_role.ecs_task_execution_role.name
  policy     = data.aws_iam_policy_document.additional_permission_policy.json
  depends_on = [aws_iam_role.ecs_task_execution_role] # To avoid the ERROR: waiting for IAM Role Policy
}
# task role
resource "aws_iam_role_policy" "ecs_task_role" {
  name       = "additional_permission_policy"
  role       = aws_iam_role.ecs_task_role.name
  policy     = data.aws_iam_policy_document.ecs_task_role.json
  depends_on = [aws_iam_role.ecs_task_role] # To avoid the ERROR: waiting for IAM Role Policy
}
