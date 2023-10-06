#creating a vpc in aws 
resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr

  tags = {
    Name = "vpc_terraform"
  }
}
#note you  can have same names for different resources
#creating a subnet
resource "aws_subnet" "main1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.subnet_cidr1
  availability_zone = var.az1
  map_public_ip_on_launch = var.public_ip_on_launch

  tags = {
    Name = "Main1-subnet"
  }
}

resource "aws_key_pair" "deployer" {
  key_name = var.key_name
  public_key = file("~/.ssh/id_rsa.pub")
#   tags = local.common_tags
}

#this block is getting latest ubuntu ami
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}
#creating ec2 instanceusing latest ubuntu image
resource "aws_instance" "this" {
  ami                     = data.aws_ami.ubuntu.id
  instance_type            = var.instance_type
#   associate_public_ip_address = true
#   availability_zone = "us-east-2a"
subnet_id = aws_subnet.main1.id
  vpc_security_group_ids = [aws_security_group.allow_tls.id]
  key_name = aws_key_pair.deployer.key_name
  user_data = file("apache.sh")
  tags = {name="EC2-terraform"}

}

output "ec2_public-ip" {
  value = aws_instance.this.public_ip
}