# AMI lookup for this Jenkins Server
data "aws_ami" "jenkins_server_dup" {
  most_recent      = true
  owners           = ["self"]

  filter {
    name   = "name"
    values = ["amazon-linux-for-jenkins*"]
  }
}

resource "aws_key_pair" "jenkins_server_dup" {
  key_name   = "jenkins_dup"
  public_key = "${file("jenkins_server.pub")}"
}

# lookup the security group of the Jenkins Server
data "aws_security_group" "jenkins_server_dup" {
   id = "${aws_security_group.jenkins_server_dup.id}"
  # name = "jenkins*"
  # filter {
  #   name   = "Group_Name"
  #   values = ["jenkins_server_dup*"]
  # }
}

# userdata for the Jenkins server ...
data "template_file" "jenkins_server_dup" {
  template = "${file("scripts/jenkins_server_dup.sh")}"

  vars ={
    env = "default"
    jenkins_admin_password = "admin"
  }
}

# output "subnetid_sk" {
#     value = "${data.aws_subnet_ids.default_public.id}"
# }

# the Jenkins server itself
resource "aws_instance" "jenkins_server_dup" {
  ami                    		= "${data.aws_ami.jenkins_server_dup.image_id}"
  instance_type          		= "t3a.large"
  key_name               		= "${aws_key_pair.jenkins_server_dup.key_name}"
  subnet_id              		= "${data.aws_subnet.filtered_subnets.id}"
  vpc_security_group_ids 		= ["${data.aws_security_group.jenkins_server_dup.id}"]
  iam_instance_profile   		= "Admin"
  user_data              		= "${data.template_file.jenkins_server_dup.rendered}"

  tags = {
    Name = "jenkins_server_dup"
  }

  root_block_device {
    delete_on_termination = true
  }
}

output "jenkins_server_dup_ami_name" {
    value = "${data.aws_ami.jenkins_server_dup.name}"
}

output "jenkins_server_dup_ami_id" {
    value = "${data.aws_ami.jenkins_server_dup.id}"
}

output "jenkins_server_dup_public_ip" {
  value = "${aws_instance.jenkins_server_dup.public_ip}"
}

output "jenkins_server_dup_private_ip" {
  value = "${aws_instance.jenkins_server_dup.private_ip}"
}