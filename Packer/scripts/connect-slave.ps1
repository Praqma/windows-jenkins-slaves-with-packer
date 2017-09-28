param(
    [parameter(Mandatory=$TRUE,Position=0)]
      [string] $slave_name
    )

write-output "Starting Jenkins slave ... "
write-host "(host) Starting Jenkins slave  ... "

$url = "$env:MASTER_URL/computer/$slave_name/slave-agent.jnlp"
Start-Process java -ArgumentList '-jar', 'slave.jar', '-jnlpUrl', $url, '-jnlpCredentials', $env:JENKINS_CREDENTIAL  -RedirectStandardOutput '.\console.out' -RedirectStandardError '.\console.err'

Exit 0
