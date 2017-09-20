Packer is used to generate machine images from templates. The templates define how to build the image using builders (specific to the target environment, e.g., AWS or VirtualBox) and provisioners which are used to provision software and perform the required setup in the image. [Packer documentation](https://www.packer.io/intro/getting-started/install.html) provides a good guide to get started.

Here, Packer is used for creating Windows Server 2016 AWS AMI which is configured to host Jenkins build slaves.

-----
## Contents of this directory

 - **ec2-userdata.ps1** is a powershell script used to configure the Windows instance while it is booting. [User data](http://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/ec2-instance-metadata.html) is an AWS feature to execute commands on an instance while it is booting.
 - **packer-win-ami.json** is the packer template.

--------
## Windows Specifics

The main distinction when using Packer to create windows images is that the communicator used to communicate with the windows instance while it is being setup is WinRM (Windows Remote Management).

Unlike SSH on Linux, WinRM needs to be configured on the windows instance before packer can connect to it to provision software on the instance.
This can be done through user data. When Packer launches a new instance on AWS to use to build the image, it can pass user data script to AWS who will run that script on the instance during its boot. The [ec2-userdata.ps1](ec2-userdata.ps1) contains that setup opening ports and adding listeners for WinRM. More details about this set up can be found [here](http://blog.petegoo.com/2016/05/10/packer-aws-windows/).

> If you face problems with WinRM and want to check it is running, check [this page](https://docs.microsoft.com/en-us/powershell/module/microsoft.wsman.management/test-wsman?view=powershell-5.1) for some useful commands

-------

**Problem**: when you create an instance from the generated AMI, it inherits the AMI password and skips executing any new user data because it has been flagged that the instance has been started before (when the parent instance of the AMI -used by Packer- was started).

> **Note:** "User data is executed only at launch. If you     stop an instance, modify the user data, and start the instance, the new user data is not executed automatically." [[AWS documentation]](http://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/ec2-instance-metadata.html#instancedata-add-user-data)

**Solution**: you need to configure the instance used for creating the AMI (during Packer provisioning) to treat the next boot as a new launch (which means allocating a new random password and executing any new user data script).
On Windows Server 2016, this can be done using [EC2Launch](http://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/ec2launch.html). Older Windows versions are configured using [EC2Config](http://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/UsingConfig_WinAMI.html).

>The EC2Launch scripts triggering the instance initialization can be found in:
    C:\ProgramData\Amazon\EC2-Windows\Launch\Scripts\

When an instance is launched for the first time (from AWS image), it will run the initialization script (which has been configured by AWS as a windows service to run at boot time) and at the end of this initialization, the script will deregister this service. Meaning that the initialization will not happen on the next boot of the instance. The next boot can be when an instance is launched from the Packer-generated image.

To configure the packer image to run the initialization scripts on the next boot, you can execute the following command on the windows instance (during packer provisioning):

    ./C:\ProgramData\Amazon\EC2-Windows\Launch\Scripts\InitializeInstance.ps1 -Schedule

-------

## reseting the EC2 instance config files to reactivate starting child instances from scratch (i.e. allocate a random password and execute user data scripts)

The following script can be used (source: https://stackoverflow.com/a/37562488/770834)

    $configFile = "C:\Program Files\Amazon\Ec2ConfigService\Settings\Config.xml"
    [xml] $xdoc = get-content $configFile
    $xdoc.SelectNodes("//Plugin") |?{ $_.Name -eq "Ec2HandleUserData"} |%{ $_.State = "Enabled" }
    $xdoc.SelectNodes("//Plugin") |?{ $_.Name -eq "Ec2SetComputerName"} |%{ $_.State = "Enabled" }
    $xdoc.OuterXml | Out-File -Encoding UTF8 $configFile

    $configFile = "C:\Program Files\Amazon\Ec2ConfigService\Settings\BundleConfig.xml"
    [xml] $xdoc = get-content $configFile
    $xdoc.SelectNodes("//Property") |?{ $_.Name -eq "AutoSysprep"} |%{ $_.Value = "Yes" }
    $xdoc.OuterXml | Out-File -Encoding UTF8 $configFile

-------
## Usage example

    packer build -var region=<<aws_region>> \
    -var instance_type=<<instance_type>> \
    -var aws_access_key=<<aws_access_key>> \
    -var aws_secret_key=<<aws_secret_key>> \
    packer-win-ami.json

> **Note** make sure the AWS access keys you use are associated with enough privileges to perform the required steps in your packer template. More details can be found [here](https://www.packer.io/docs/builders/amazon.html#specifying-amazon-credentials)
