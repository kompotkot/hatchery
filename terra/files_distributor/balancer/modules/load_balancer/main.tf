# Load Balancer and Target Group main

resource "aws_lb" "hatchery_lb" {
  name               = var.lb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.hatchery_security_group_id]
  subnets            = [var.hatchery_sbn_public_id]

  tags = {
    Product = var.tag_resource
  }
}

resource "aws_lb_target_group" "hatchery_tg_lambda" {
  name        = "hatchery-tg-lambda"
  target_type = "lambda"

#   lambda_multi_value_headers_enabled = true

  tags = {
    Product = var.tag_resource
  }
}

resource "aws_lambda_permission" "hatchery_with_lb" {
  statement_id  = "AllowExecutionFromlb"
  action        = "lambda:InvokeFunction"
  function_name = var.hatchery_lambda_arn
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = aws_lb_target_group.hatchery_tg_lambda.arn
}

resource "aws_lb_target_group_attachment" "hatchery_lb_tg_lambda_attachment" {
  target_group_arn = aws_lb_target_group.hatchery_tg_lambda.arn
  target_id        = var.hatchery_lambda_arn
  depends_on       = [aws_lambda_permission.hatchery_with_lb]
}
