resource "aws_ecs_task_definition" "example_batch" {
  family = "example-batch"
  cpu = "256"
  container_definitions = ""
}