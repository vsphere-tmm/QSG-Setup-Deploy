$username = "root"
$password = "VMware1!"
$cred = New-Object System.Management.Automation.PSCredential -ArgumentList @($username,(ConvertTo-SecureString -String $password -AsPlainText -Force))
#$webServicesProxy.Credentials = $cred
#$cred = get-credential
 #$URI = New-WebServiceProxy -uri https://vcsa.lab.local/applmgmt/RPC2 -credential $cred
$URI = "https://vcsa.lab.local/applmgmt/RPC2"
$server = New-WebServiceProxy -uri $URI -namespace WebServiceProxy -class Server -Credential $cred
