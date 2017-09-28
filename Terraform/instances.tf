# creating N windows server 2016 instances ready to run Jenkins slave
resource "aws_instance" "jenkins_slaves" {
  ami                         = "${data.aws_ami.ami.image_id}"
  instance_type               = "${lookup(var.instance_types, count.index)}"
  count                       = "${var.instance_count}"
  vpc_security_group_ids      = ["${aws_security_group.Windows_Jenkins_SG.id}"]
  associate_public_ip_address = true
  subnet_id                   = "${aws_subnet.main.id}"
  user_data                   = "${file("scripts/ec2-userdata.ps1")}"
  # root_block_device           = {
  #                                  volume_size = 65
  #                               }
  # key_name                  = "aws-k8s-win"
  tags                        = {
                                   Name  = "Terraform-Win-Jenkins-Slave"
                                }
  depends_on                  = ["aws_internet_gateway.gw"]

   provisioner "remote-exec" {
     inline = [
         "net user Administrator ${var.admin_password}",
         "powershell.exe .\\connect-slave.ps1 -slave_name ${lookup(var.slave_names, count.index)}"
        ]
      connection {
        type     = "winrm"
        user     = "Administrator"
        password = "thisIsJustTemporary!"
      }
    }

}
