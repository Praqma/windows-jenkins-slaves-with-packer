data "aws_ami" "ami" {
  most_recent      = true

  filter {
    name   = "name"
    values = ["packer-jenkins-win-slave*"]
  }

}


# fetching the windows vpc's main route table
data "aws_route_table" "win_vpc_rt" {
  vpc_id = "${aws_vpc.windows_vpc.id}"

  filter{
    name    = "association.main"
    values  = ["true"]
  }
}
