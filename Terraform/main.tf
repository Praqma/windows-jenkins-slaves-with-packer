# AWS parameters
provider "aws" {
  access_key   = "${var.access_key}"
  secret_key   = "${var.secret_key}"
  region       = "${var.region}"
}


# creating vpc to add windows instances in
resource "aws_vpc" "windows_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags {
    Name = "Windows_Jenkins_Slaves"
  }
 }

 # creating internet gateway
 resource "aws_internet_gateway" "gw" {
   vpc_id = "${aws_vpc.windows_vpc.id}"

   tags {
     Name = "windows_vpc_gateway"
   }
 }

 # creating main subnet in the VPC
 resource "aws_subnet" "main" {
  vpc_id                  = "${aws_vpc.windows_vpc.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags {
    Name = "Main-Windows-VPC-Subnet"
  }
}



# creating route table
resource "aws_route_table" "rt" {
  vpc_id       = "${aws_vpc.windows_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }


  tags {
    Name = "main-rt"
  }
}

# associating route table and subnet
resource "aws_route_table_association" "a" {
  subnet_id      = "${aws_subnet.main.id}"
  route_table_id = "${aws_route_table.rt.id}"
}
