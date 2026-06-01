data "aws_ssm_parameter" "vpn_sg_id" {
  name = "/${var.project_name}/${var.environment}/vpn_sg_id"
}

data "aws_ssm_parameter" "public_subnet_ids" {
  name = "/${var.project_name}/${var.environment}/public_subnet_ids"
}

data "aws_ami" "ami_info"{
    most_recent = true
    owners = ["679593333241"]
    filter{
        name = "name"
        values = ["OpenVPN Access Server Community Image-*"]
    }
    filter{
        name = "root-device-type"
        values = ["ebs"]
    }
    filter{
        name = "virtualization-type"
        values = ["hvm"]
    }
    filter{
        name = "root-device-name"
        values = ["/dev/sda1"]
    }
}

# data "aws_ami" "ami_info" {
#   most_recent = true
#   owners      = ["amazon"]

#   filter {
#     name   = "name"
#     values = ["al2023-ami-*-x86_64"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }

#   filter {
#     name   = "root-device-type"
#     values = ["ebs"]
#   }
# }
