param(
    [parameter(Mandatory=$TRUE,Position=0)]
      [string] $slave_name
    )

write-output "Starting Jenkins slave ... "
write-host "(host) Starting Jenkins slave  ... "

start powershell {java -jar slave.jar -jnlpUrl $env:MASTER_URL/computer/$slave_name/slave-agent.jnlp -jnlpCredentials $env:JENKINS_CREDENTIAL}
Exit 0
