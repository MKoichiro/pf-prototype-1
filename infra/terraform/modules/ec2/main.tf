# Links to official documentation:
# * Resource: aws_instance                    [https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance]
# * Resource: aws_lb_target_group_attachment  [https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment]

resource "aws_instance" "bastion" {
  ami           = "ami-0a290015b99140cd1"
  instance_type = "t2.micro"

  vpc_security_group_ids      = var.ec2_sg_ids
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true

  user_data                   = file("${path.module}/user_data.sh")
  user_data_replace_on_change = true

  tags = {
    Name = "${var.env_prefix}-pf-ec2"
  }
}

resource "aws_lb_target_group_attachment" "bastion" {
  target_group_arn = var.alb_bastion_tg_arn
  target_id        = aws_instance.bastion.id
}
