data "aws_iam_policy_document" "ecs_task_execution_role_policy" {
  source_json = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"

  statment {
    effect = "Allow"
    actions = ["ssm:GetParameters", "kms:Decrypt"]
    resource = ["*"]
  }
}

module "ecs_task_execution_role" {
  source = "./iam-role"
  name = "ecs-task-execution"
  identifier = "ecs-tasks.amazonaws.com"
  policy = "${data.aws_iam_policy_document.ecs_task_execution_role_policy.json}"
}

resource "aws_ecs_task_definition" "example" {
  family = "example"
  cpu = "256"
  memory = "512"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions = file("./container_definitions.json")
  execution_role_arn = "${module.ecs_task_execution_role.iam_role_arn}"
}
