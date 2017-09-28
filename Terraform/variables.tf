# AWS access and secret keys ..
# check http://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html for details on how to get them
variable "access_key" {}
variable "secret_key" {}

# The AWS region to launch the instances in
variable "region" {
  default = "eu-west-1"
}

# This is no longer used as image id is fetched from AWS account
# The AMI to launch images from --note: AMI ids vary depending on AWS regoins
# variable "ami" {
#   default= "ami-0537ce7c"
# }

# The number of instances to be launched
variable "instance_count" {
  default = "1"
}

# defining the Administrator password on the created windows instances
variable "admin_password" {
  default = "terraformSetPassword!"
}


# defining the Jenkins master URL
# variable "master_URL" {
#   default = ""
# }

# defining different instance types
# pass values as:
# -var 'instance_types={ "0" = "t2.micro", "1" = "t2.medium", ... }'
variable "instance_types" {
  type = "map"
  default = {
    "0" = "t2.micro"
  }
}

# defining secrets for launching Jenkins slaves on Windows instances
# pass values as:
# -var 'slave_secrets={ "0" = "sssss", "1" = "yyyyy", ... }'
# variable "slave_secrets" {
#   type = "map"
# }

# defining the names of the created Jenkins slaves on Windows instances
# pass values as:
# -var 'slave_names={ "0" = "name0", "1" = "name1", ... }'
variable "slave_names" {
  type = "map"
}
