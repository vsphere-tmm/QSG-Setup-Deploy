param(
        [Parameter(Mandatory=$true)][string]$vc_server,
        [Parameter(Mandatory=$true)][String]$vc_username,
        [Parameter(Mandatory=$true)][String]$vc_password,
        [Parameter(Mandatory=$true)][String]$CISserverUsername,
        [Parameter(Mandatory=$true)][String]$CISserverPassword,
        [Parameter()][String]$users_base_dn = "CN=Users,DC=lab1,DC=local",
        [Parameter()][String]$groups_base_dn = "DC=lab1,DC=local",
        [Parameter()][String]$adusername = "CN=Administrator,CN=Users,DC=lab1,DC=local",
        [Parameter()][VMware.VimAutomation.Cis.Core.Types.V1.Secret]$adpassword = "VMware1!",
        [Parameter()][String]$server_endpoint1 = "ldaps://mgt-dc-01.lab1.local:636",
        [Parameter()][String]$server_endpoint2
)
