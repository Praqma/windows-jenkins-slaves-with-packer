---
maintainer: sami-alajrami
---

# windows-jenkins-slaves-with-packer
This repository shows how to use Packer to provision Windows jenkins-slaves-ready VM images on AWS and how the slaves can be launched with Terraform.

------

> Please note that running the commands below might incur costs!

You can generate the AWS AMI and store it in your AWS account by running the following command:

      cd Packer
      packer build -var region=<<aws_region>> \
      -var instance_type=<<instance_type>> \
      -var aws_access_key=<<aws_access_key>> \
      -var aws_secret_key=<<aws_secret_key>> \
      -var master_URL=<<jenkins_master_url>> \
      -var jenkins_credential=<<jenkins_jnlp_credentials>>
      packer-win-ami.json

Once you have a Jenkins master running and [slave node(s) created](https://support.cloudbees.com/hc/en-us/articles/227834227-How-to-create-a-new-node-), you can use Terraform to launch a number of Windows instances (of whatever machine types you prefer) and have them start and connect the Jenkins slaves to the master:

      cd Terraform
      terraform apply -var access_key=<<aws_access_key>> \
      -var secret_key=<<aws_secret_key>> \
      -var admin_password=<<admin_password_for_windows>> \
      -var instance_count=2 \
      -var region=eu-west-1 \
      -var 'instance_types={ "0" = "t2.micro", "1" = "t2.small"}' \
      -var 'slave_names={ "0" = "slave1_name", "1" = "slave2_name"}'
