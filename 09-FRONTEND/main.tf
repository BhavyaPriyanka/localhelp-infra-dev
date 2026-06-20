module "frontend" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "${var.project_name}-${var.environment}-${var.common_tags.Component}"

  instance_type          = "t3.micro"

root_block_device = {
  size                  = 40
  type                  = "gp3"
  delete_on_termination = true
}
  vpc_security_group_ids = [data.aws_ssm_parameter.frontend_sg_id.value]
  subnet_id              = local.public_subnet_id
  ami                    = data.aws_ami.ami_info.id
  key_name               = aws_key_pair.frontend_key.key_name




  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-${var.common_tags.Component}"
  })
}


# ---------------------------
# KEY PAIR (optional but OK if you use SSH manually)
# ---------------------------
resource "aws_key_pair" "frontend_key" {
  key_name   = "${var.project_name}-${var.environment}-frontend-key"
  public_key = tls_private_key.frontend.public_key_openssh
}

resource "tls_private_key" "frontend" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "null_resource" "frontend" {

  triggers = {
    instance_id = module.frontend.id,
    # git_commit = var.git_commit
    always_run = timestamp()
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = tls_private_key.frontend.private_key_pem
    host        = module.frontend.private_ip
  }

  # Upload main script
  provisioner "file" {
    source      = "${var.common_tags.Component}.sh"
    destination = "/tmp/${var.common_tags.Component}.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "set -euxo pipefail",
      "ls -l /tmp",
      "chmod +x /tmp/${var.common_tags.Component}.sh",
      "bash -x /tmp/${var.common_tags.Component}.sh ${var.common_tags.Component} ${var.environment}",
      "sudo git config --global --add safe.directory /opt/localhelp/frontend"
    ]
  }
}

resource "aws_ec2_instance_state" "frontend_stop" {
  instance_id = module.frontend.id
  state       = "stopped"
  depends_on  = [ null_resource.frontend ]
}

resource "aws_ami_from_instance" "frontend_ami" {
  name               = "${var.project_name}-${var.environment}-${var.common_tags.Component}"
  source_instance_id = module.frontend.id

  depends_on = [ aws_ec2_instance_state.frontend_stop ]
}

resource "null_resource" "frontend_delete" {
 triggers = {
      instance_id = module.frontend.id # this will be triggered everytime instance is created
    }

  provisioner "local-exec" {
    command = "aws ec2 terminate-instances --instance-ids ${module.frontend.id}"
  }


  depends_on = [ aws_ami_from_instance.frontend_ami ]
}

resource "aws_lb_target_group" "frontend" {
  name     = "${var.project_name}-${var.environment}-${var.common_tags.Component}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_ssm_parameter.vpc_id.value
   health_check {
    path                = "/health"
    port                = 80
    protocol            = "HTTP"
    matcher             = "200"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_launch_template" "frontend" {
  name = "${var.project_name}-${var.environment}-${var.common_tags.Component}"

  image_id = aws_ami_from_instance.frontend_ami.id

  instance_initiated_shutdown_behavior = "terminate"

  instance_type = "t3.micro"
  update_default_version = true

  vpc_security_group_ids = [ data.aws_ssm_parameter.frontend_sg_id.value ]

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      var.common_tags,
      {
      Name = "${var.project_name}-${var.environment}-${var.common_tags.Component}"
      }
    )
  }
}

resource "aws_autoscaling_group" "frontend" {
  name                      = "${var.project_name}-${var.environment}-${var.common_tags.Component}"
  max_size                  = 5
  min_size                  = 1
  health_check_grace_period = 60
  health_check_type         = "ELB"
  desired_capacity          = 1
  target_group_arns         = [aws_lb_target_group.frontend.arn]

  launch_template {
    id      = aws_launch_template.frontend.id
    version = "$Latest"
  }
  vpc_zone_identifier       = split(",",data.aws_ssm_parameter.public_subnet_ids.value)

  instance_refresh {
    strategy = "Rolling"
    preferences{
      min_healthy_percentage = 50
    }
    triggers = ["launch_template"]
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-${var.environment}-${var.common_tags.Component}"
    propagate_at_launch = true
  }

  timeouts {
    delete = "15m"
  }

  tag {
    key                 = "Project"
    value               = "${var.project_name}"
    propagate_at_launch = false
  }
}

resource "aws_autoscaling_policy" "frontend" {
  name                   = "${var.project_name}-${var.environment}-${var.common_tags.Component}"
  policy_type           = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.frontend.name

   target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
     target_value = 10.0
}
}

resource "aws_lb_listener_rule" "frontend" {
  listener_arn = data.aws_ssm_parameter.web_alb_listener_arn_https.value
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }

  condition {
     host_header {
      values = ["web-${var.environment}.${var.zone_name}"]
    }
  }

}