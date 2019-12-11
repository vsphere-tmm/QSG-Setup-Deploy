#Connect to VAMI
Connect-CisServer -server 192.168.1.183 -User administrator@vsphere.local -Password VMware1! -Force

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


$s = Get-CisService "com.vmware.vcenter.identity.providers"
 
$adfsSpec = @{
    "name" = "Microsoft ADFS";
    "config_tag" = "Oidc";
    "upn_claim" = "upn";
    "groups_claim" = "group";
    "oidc" = @{
        "client_id" = "<client id>";
        "client_secret" = "<client secret>";
        "discovery_endpoint" = "https://adfs.pslabs.eng.vmware.com/adfs/.well-known/openid-configuration";
        "claim_map" = @{};
    };
    "idm_protocol" = "LDAP";
    "active_directory_over_ldap" = @{
        "users_base_dn" = "CN=Users,DC=pslabs,DC=eng,DC=vmware,DC=com";
        "groups_base_dn" = "DC=pslabs,DC=eng,DC=vmware,DC=com";
        "user_name" = "CN=Federation Test User,CN=Users,DC=pslabs,DC=eng,DC=vmware,DC=com";
        "password" = "Admin!23";
        "server_endpoints" = @( "ldaps://psqe-dns01.pslabs.eng.vmware.com:636", "ldaps://psqe-dns02.pslabs.eng.vmware.com:636");
        "cert_chain" = @{
            "cert_chain" = @(
                "-----BEGIN CERTIFICATE-----....",
                "-----BEGIN CERTIFICATE-----...."
            )
        }
    };
    "is_default" = $true
}
$s.create($adfsSpec)
 