data "aws_ssm_parameter" "frontend_sg_id" {
  name = "/${var.project_name}/${var.environment}/frontend_sg_id"
}

data "aws_ssm_parameter" "public_subnet_ids" {
  name = "/${var.project_name}/${var.environment}/public_subnet_ids"
}

data "aws_ssm_parameter" "vpc_id" {
  name = "/${var.project_name}/${var.environment}/vpc_id"
}

data "aws_ssm_parameter" "web_alb_listener_arn_https" {
  name = "/${var.project_name}/${var.environment}/web_alb_listener_arn_https"
}




# 
# data "aws_ami" "ami_info"{
#     most_recent = true
#     owners = ["837206354502"]
#     filter{
#         name = "name"
#         values = ["MY-AMI-*"]
#     }
#     filter{
#         name = "root-device-type"
#         values = ["ebs"]
#     }
#     filter{
#         name = "virtualization-type"
#         values = ["hvm"]
#     }
#     filter{
#         name = "root-device-name"
#         values = ["/dev/sda1"]
#     }
# }

data "aws_ami" "ami_info" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}
