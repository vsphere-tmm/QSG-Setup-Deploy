#This is the name of your vCenter. IP address or FQDN
$vcname = "192.168.1.185"

#This is the name of your application group and will be used as the root name of the application group components and applications.
$ClientRoleIdentifier = "VC-ADFS-185"
$AppGroupID = $ClientRoleIdentifier + "-GID"

# Creates a new GUID for use by the application group
[string]$identifier = (New-Guid).Guid
# The following are the redirect URL's on vCenter. These should match the URLs in the UI setup.
$redirect1 = "https://$vcname/ui/login"
$redirect2 = "https://$vcname/ui/login/oauth2/authcode"


Write-Output "Configuring ADFS"

Write-Output "Create the new Application Group in ADFS"
New-AdfsApplicationGroup -Name $ClientRoleIdentifier #-ApplicationGroupIdentifier $identifier

Write-Output "Create the ADFS Server Application and generate the client secret"
$ADFSApp = Add-AdfsServerApplication -Name "VC - Server app 185" -ApplicationGroupIdentifier $ClientRoleIdentifier -RedirectUri $redirect1,$redirect2  -Identifier $Identifier -GenerateClientSecret

Write-Output "#Create the client secret"
$client_secret = $ADFSApp.ClientSecret
Write-Output "Please write down and save the following Client Secret: " ($client_secret)
Write-Output "Please write down and save the following Client Secret: " ($ADFSApp.ClientSecret)

Write-Output "#Create the ADFS Web API application and configure the policy name it should use"
Add-AdfsWebApiApplication -ApplicationGroupIdentifier $ClientRoleIdentifier  -Name "VC Web API" -Identifier $identifier -AccessControlPolicyName "Permit everyone"

Write-Output "#Grant the ADFS Application the allatclaims and openid permissions"
Grant-AdfsApplicationPermission -ClientRoleIdentifier $identifier -ServerRoleIdentifier $identifier -ScopeNames @('allatclaims', 'openid')

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

#Write out the tranform rules file

$transformrule |Out-File -FilePath .\issueancetransformrules.tmp -force -Encoding ascii

# Name the Web API Application and define its Issuance Transform Rules using an external file.
Set-AdfsWebApiApplication -Name "$ClientRoleIdentifier - Web API" -TargetIdentifier $identifier -IssuanceTransformRulesFile .\issueancetransformrules.tmp

#$report = ./report_(Get-Date -Format yyyyddmmm_hhmmtt).txt

Write-Output "Please write down and save the following Client Identifier" ($ClientRoleIdentifier)

Write-Output "Please write down and save the following Client Identifier UID" ($identifier)

Write-Output "Please write down and save the following Client Secret: " ($client_secret)

Write-Output ""

$openidurl = (Get-AdfsEndpoint -addresspath "/adfs/.well-known/openid-configuration")
write-output "OpenID URL is: " $openidurl.FullUrl.OriginalString

#-----------------------------------------------------------------------
