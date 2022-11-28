provider "aws" {
    access_key = "<your ac key here>"
    secret_key = "<your sec key here>"
    region = "us-east-1"
}

data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }
    
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"]
}

variable "names"{
  type = list(string)
  default = ["balancer","app01","app02"]
}

data "aws_key_pair" "keys" {
  key_name           = "<your key-pair name here>"
  include_public_key = true
}

resource "aws_instance" "ec2_instance" {
    count = 3
    ami = data.aws_ami.ubuntu.id
    instance_type = "t2.micro"
    key_name = data.aws_key_pair.keys.key_name
    tags = {
       Name = "${element(var.names,count.index)}"
    }
}

resource "aws_eip" "eip"{
    count = 3
    instance = aws_instance.ec2_instance[count.index].id
}

output "balancer" {
value = "${aws_instance.ec2_instance[0].public_ip}"
}
output "web1" {
value = "${aws_instance.ec2_instance[1].public_ip}"
}
output "web2" {
value = "${aws_instance.ec2_instance[2].public_ip}"
}
