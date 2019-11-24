# AMI lookup for this Jenkins Server
data "aws_ami" "jenkins_server" {
  most_recent      = true
  owners           = ["self"]

  filter {
    name   = "name"
    values = ["amazon-linux-for-jenkins*"]
  }
}

resource "aws_key_pair" "jenkins_server" {
  key_name   = "jenkins_server"
  public_key = "${file("jenkins_server.pub")}"
}

# lookup the security group of the Jenkins Server
data "aws_security_group" "jenkins_server" {
   id = "${aws_security_group.jenkins_server.id}"
  # name = "jenkins*"
  # filter {
  #   name   = "Group_Name"
  #   values = ["jenkins_server*"]
  # }
}

# userdata for the Jenkins server ...
data "template_file" "jenkins_server" {
  template = "${file("scripts/jenkins_server.sh")}"

  vars ={
    env = "default"
    jenkins_admin_password = "mysupersecretpassword"
  }
}

# output "subnetid_sk" {
#     value = "${data.aws_subnet_ids.default_public.id}"
# }

# the Jenkins server itself
resource "aws_instance" "jenkins_server" {
  ami                    		= "${data.aws_ami.jenkins_server.image_id}"
  instance_type          		= "t2.micro"
  key_name               		= "${aws_key_pair.jenkins_server.key_name}"
  subnet_id              		= "${data.aws_subnet.filtered_subnets.id}"
  vpc_security_group_ids 		= ["${data.aws_security_group.jenkins_server.id}"]
  iam_instance_profile   		= "Admin"
  user_data              		= "${data.template_file.jenkins_server.rendered}"

  tags = {
    Name = "jenkins_server"
  }

  root_block_device {
    delete_on_termination = true
  }
}

output "jenkins_server_ami_name" {
    value = "${data.aws_ami.jenkins_server.name}"
}

output "jenkins_server_ami_id" {
    value = "${data.aws_ami.jenkins_server.id}"
}

output "jenkins_server_public_ip" {
  value = "${aws_instance.jenkins_server.public_ip}"
}

output "jenkins_server_private_ip" {
  value = "${aws_instance.jenkins_server.private_ip}"
}