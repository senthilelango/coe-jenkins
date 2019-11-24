# lookup for the "default" VPC
data "aws_vpc" "default_vpc" {
  default = true
}

output "vpc_id_sk" {
    value = "${data.aws_vpc.default_vpc.id}"
}
# subnet list in the "default" VPC
# The "default" VPC has all "public subnets"
data "aws_subnet_ids" "default_public" {
  vpc_id = "${data.aws_vpc.default_vpc.id}"

}

data "aws_subnet" "filtered_subnets" {
  # count = "${length(data.aws_subnet_ids.default_public.ids)}"
  # id    = "${data.aws_subnet_ids.default_public.ids[count.index]}"
  vpc_id = "${data.aws_vpc.default_vpc.id}"
  filter {
    name   = "tag:Name"
    values = ["default_public"]
  }
}

output "subnetid_sk1" {
    value = "${data.aws_subnet.filtered_subnets.id}"
}