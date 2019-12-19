$errorcode = {
    # The following are the AD over LDAP settings:
$users_base_dn = "CN=Users,DC=lab1,DC=local"
$groups_base_dn = "DC=lab1,DC=local"
$adusername = "CN=Administrator,CN=Users,DC=lab1,DC=local"
[VMware.VimAutomation.Cis.Core.Types.V1.Secret]$adpassword = "VMware1!"
$CISserverUsername = "administrator@vsphere.local"
$CISserverPassword = "VMware1!"
$server_endpoint1 = "ldap://mgt-dc-01.lab1.local:389"
#$server_endpoint2 = "ldaps://FQDN2:636"
#$ad_cert_chain = ""
$ad_cert_chain = @("-----BEGIN CERTIFICATE-----
MIIFnzCCBIegAwIBAgITHgAAABTRT3kDhD7sBwAAAAAAFDANBgkqhkiG9w0BAQUF
ADBDMRUwEwYKCZImiZPyLGQBGRYFbG9jYWwxFDASBgoJkiaJk/IsZAEZFgRsYWIx
MRQwEgYDVQQDEwtOZXcgUm9vdCBDQTAeFw0xOTA5MTcyMDExMzJaFw0yMDAxMjAx
NzEyMDlaMBoxGDAWBgNVBAMTD2FkZnMubGFiMS5sb2NhbDCCASIwDQYJKoZIhvcN
AQEBBQADggEPADCCAQoCggEBAMHQg+pR+I6mzgK7bamXtu9tCFCU6UilsNIuEHny
SXKfbUsTV9UF02689+VrndJAon4bnOkdzBO1rUbiNzC3PuI+HE0B+rZoqg6yAKe0
xb+W7/qhwrL/IzWb+WbRq5Eu0goLzn346dn5OeJ5jCtl92Ru30ZDvnwESefGSZiY
q4PFrNFTa70fSQZaHJz2HvFYlFdtgnoYsPx5jX/6FSiV4ZXlBcJlWCTuBAODvg1y
VRxEGNpMufYxeWsqCnq6/j0SI0cF3sPKTD9KzZrIoGjig2Y8PA3GLfF1BgYBlfTh
2ZhZgQJwdWHF27cLVHI9zEARxOYdFQTJP7UYfEhzKswBAQUCAwEAAaOCArMwggKv
MD4GCSsGAQQBgjcVBwQxMC8GJysGAQQBgjcVCIfK5DGF+OhZheWXMoOxoiyEvqFl
gQiEwbQrhpKOFAIBZAIBCjATBgNVHSUEDDAKBggrBgEFBQcDATAOBgNVHQ8BAf8E
BAMCBaAwGwYJKwYBBAGCNxUKBA4wDDAKBggrBgEFBQcDATAdBgNVHQ4EFgQUaQqS
weXiL6GJs+h0iLJ2++AIoGcwVwYDVR0RBFAwToIYY2VydGF1dGguYWRmcy5sYWIx
LmxvY2Fsgg9hZGZzLmxhYjEubG9jYWyCIWVudGVycHJpc2VyZWdpc3RyYXRpb24u
bGFiMS5sb2NhbDAfBgNVHSMEGDAWgBQEVAvHsE2WFlgv8SduOLdR+qFuVDCBzgYD
VR0fBIHGMIHDMIHAoIG9oIG6hoG3bGRhcDovLy9DTj1OZXclMjBSb290JTIwQ0Es
Q049TUdULURDLTAxLENOPUNEUCxDTj1QdWJsaWMlMjBLZXklMjBTZXJ2aWNlcyxD
Tj1TZXJ2aWNlcyxDTj1Db25maWd1cmF0aW9uLERDPWxhYjEsREM9bG9jYWw/Y2Vy
dGlmaWNhdGVSZXZvY2F0aW9uTGlzdD9iYXNlP29iamVjdENsYXNzPWNSTERpc3Ry
aWJ1dGlvblBvaW50MIHABggrBgEFBQcBAQSBszCBsDCBrQYIKwYBBQUHMAKGgaBs
ZGFwOi8vL0NOPU5ldyUyMFJvb3QlMjBDQSxDTj1BSUEsQ049UHVibGljJTIwS2V5
JTIwU2VydmljZXMsQ049U2VydmljZXMsQ049Q29uZmlndXJhdGlvbixEQz1sYWIx
LERDPWxvY2FsP2NBQ2VydGlmaWNhdGU/YmFzZT9vYmplY3RDbGFzcz1jZXJ0aWZp
Y2F0aW9uQXV0aG9yaXR5MA0GCSqGSIb3DQEBBQUAA4IBAQAUXswUCnDuJhVgfT9B
YthKKL6umCI2vHQ2vxTvmdWuMfGT3U++uuGj4FlmPDEHeSHoNa725s33aFVgs5G/
skRB/ZIqSG6YgkFB1c7LgbUY4o7ai7BeArQVJXKspV7mWaWVomElSgOCCfgqufrM
sqt/VlKA0zqFk63I+xkhL5bZViCrQdvzfEOx3o2bHREL845zhWt0ZF7wX1tgrALm
jNZOJuLbOui14K8zlfyB7fUFhnh3ul3Zvf7beCLPghWC7GO/Ju8pzyJsu+hOfk1m
OZBxoRyUbRXRl/51B1o3BUXDU48Ssv5v4mryYZUAYyBPNTaWSX3BxLRwyCfr3lwG
MPaW
-----END CERTIFICATE-----"
)
#                "-----BEGIN CERTIFICATE-----....",
#                "-----BEGIN CERTIFICATE-----...."


Write-Output "Configuring ADFS"

Write-Output ""

Write-Output "Create the new Application Group in ADFS"
New-AdfsApplicationGroup -Name $ClientRoleIdentifier #-ApplicationGroupIdentifier $identifier

Write-Output ""

Write-Output "Create the ADFS Server Application and generate the client secret"
$ADFSApp = Add-AdfsServerApplication -Name ($ClientRoleIdentifier + " VC - Server app") -ApplicationGroupIdentifier $ClientRoleIdentifier -RedirectUri $redirect1,$redirect2  -Identifier $Identifier -GenerateClientSecret

Write-Output ""

Write-Output "#Create the client secret"
$client_secret = $ADFSApp.ClientSecret

Write-Output ""

# Write-Output "Please write down and save the following Client Secret: " ($ADFSApp.ClientSecret)

Write-Output "Create the ADFS Web API application and configure the policy name it should use"
Add-AdfsWebApiApplication -ApplicationGroupIdentifier $ClientRoleIdentifier  -Name ($ClientRoleIdentifier + " VC Web API") -Identifier $identifier -AccessControlPolicyName "Permit everyone"

Write-Output ""

Write-Output "Grant the ADFS Application the allatclaims and openid permissions"
Grant-AdfsApplicationPermission -ClientRoleIdentifier $identifier -ServerRoleIdentifier $identifier -ScopeNames @('allatclaims', 'openid')

Write-Output ""

Write-Output "Build the transform rule for ADFS"

Write-Output ""

$transformrule = @"
@RuleTemplate = "LdapClaims"
@RuleName = "AD Groups with Qualified Long Name"
c:[Type == "http://schemas.microsoft.com/ws/2008/06/identity/claims/windowsaccountname", Issuer == "AD AUTHORITY"]
 => issue(store = "Active Directory", types = ("http://schemas.xmlsoap.org/claims/Group"), query = ";tokenGroups(longDomainQualifiedName);{0}", param = c.Value);

@RuleTemplate = "LdapClaims"
@RuleName = "Subject"
c:[Type == "http://schemas.microsoft.com/ws/2008/06/identity/claims/windowsaccountname", Issuer == "AD AUTHORITY"]
 => issue(store = "Active Directory", types = ("http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier"), query = ";userPrincipalName;{0}", param = c.Value);

@RuleTemplate = "LdapClaims"
@RuleName = "User Principal Name"
c:[Type == "http://schemas.microsoft.com/ws/2008/06/identity/claims/windowsaccountname", Issuer == "AD AUTHORITY"]
 => issue(store = "Active Directory", types = ("http://schemas.xmlsoap.org/ws/2005/05/identity/claims/upn"), query = ";userPrincipalName;{0}", param = c.Value);
"@

write-Output "Write out the tranform rules file"

$transformrule |Out-File -FilePath .\issueancetransformrules.tmp -force -Encoding ascii

Write-Output ""

Write-Output "Name the Web API Application and define its Issuance Transform Rules using an external file"

Set-AdfsWebApiApplication -Name "$ClientRoleIdentifier - Web API" -TargetIdentifier $identifier -IssuanceTransformRulesFile .\issueancetransformrules.tmp

Write-Output ""

Write-Output "Please write down and save the following Client Identifier" ($ClientRoleIdentifier)

Write-Output ""

Write-Output "Please write down and save the following Client Identifier UID" ($identifier)

Write-Output ""

Write-Output "Please write down and save the following Client Secret: " ($client_secret)

Write-Output ""

$openidurl = (Get-AdfsEndpoint -addresspath "/adfs/.well-known/openid-configuration")
write-output "OpenID URL is: " $openidurl.FullUrl.OriginalString

#-----------------------------------------------------------------------
Write-Output "Configuring VC..."
Write-Output "Connect to VAMI REST API"
Connect-CisServer -server $vcname -User $CISserverUsername -Password $CISserverPassword -Force

# Change Identity Provider

# Configure the following:
#Client Identifier
#Shared Secret
#OpenID Address

#Configure/create spec for AD over LDAP so VC can look up user accounts to map permissions
# Required fields:
# Base distinguished Name for Users
# Base distinguished Name for Groups
# Username
# Password
# Primary Server URL (ldap://FQDN:389)
# Secondary Server URL (ldap://FQDN:389)
# Certificate if using LDAPS

# Inform user to add AD user permissions to VC
#Write-Output "Client Secret:" $client_secret
$client_secret_string = [string]$client_secret
#Write-Output "Client Secret String:" $client_secret_string

Write-Output "Connecting to the CIS Service"
$s = Get-CisService "com.vmware.vcenter.identity.providers"

Write-Output "Build the ADFS Spec"
$adfsSpec = @{
    "is_default" = $true;
    "name" = "Microsoft ADFS";
    "config_tag" = "Oidc";
    "upn_claim" = "upn";
    "groups_claim" = "group";
    "oidc" = @{
        "client_id" = $identifier;
        "client_secret" = $client_secret_string;
        "discovery_endpoint" = $openidurl.FullUrl.OriginalString;
        "claim_map" = @{};
};
    "idm_protocol" = "LDAP";
    "active_directory_over_ldap" = @{
        "users_base_dn" = $users_base_dn;
        "groups_base_dn" = $groups_base_dn;
        "user_name" = $adusername;
        "password" = $adpassword;
        "server_endpoints" = @($server_endpoint1);
        "cert_chain" =@{
            "cert_chain" = @(
                $ad_cert_chain
            )
        }
};
}
Write-Output "Create the ADFS Spec on VC"
$s.create($adfsSpec)

}