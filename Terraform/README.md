This directory contains the Terraform templates to launch AWS windows instances from the AMI image created by packer.

Terraform provides good [getting-started documentation](https://www.terraform.io/intro/getting-started/install.html).
Windows specifics are similar to [the ones discussed for Packer](../Packer/README.md#windows-specifics).

The templates create a new VPC, subnet, security group etc. and then launch an EC2 windows instance inside that VPC and run the Jenkins slave inside it.

-------

## Usage example

    terraform apply -var access_key=<<aws_access_key>> \
    -var secret_key=<<aws_secret_key>> \
    -var admin_password=<<admin_password_for_windows>> \
    -var instance_count=<<number_of_instances_to_launch>> \
    -var region=<<aws_region>> \
    -var instance_types={"0"="<<machine0_instance_type>>"} \
    -var slave_names={"0"="<slave0_name>"}
