function Retrieve-ServerCertFromSocket ($hostname, $port=443, $SNIHeader, [switch]$FailWithoutTrust)
<#
    .Description
    Connect to a remote server using an SSL connection and retrieve the certificate.

    .Parameter Hostname
    The hostname or IP of the server you wish to retrieve the certificate from. Note that this name 
    will be passed in the SNI authentication header if SNIHeader is null.

    .Paremeter Port 
    The port you want to connect to, default is 443.

    .Paremeter SNIHeader
    This value will be passed to the server in the SNI authentication, useful for checking fall back
    certificates and certificates listening on different endpoints.

    .Parameter FailWithoutTrust
    Enabling this switch will cause your connection to fail if you connect to a server where the certificate
    is not trusted, because it doesn't chain or is expired. Instead of getting a certificate you will get a 
    catchable exception.

    .Example Retrieve-ServerCertFromSocket www.wrish.com 443 | Export-Certificate -FilePath C:\temp\test.cer ; start c:\temp\test.cer
    Export the certificate from a server to a file, and then open that file to view the certificate being used

    .Example Retrieve-ServerCertFromSocket www.wrish.com 443 | fl subject,*not*,Thumb*,ser*
    Retrieve a certificate and display the mail useful values to the screen.

#>
{
    if (!$SNIHeader) {
        $SNIHeader = $hostname
    }
    
    $cert = $null
    try {
        $tcpclient = new-object System.Net.Sockets.tcpclient
        $tcpclient.Connect($hostname,$port)

        #Authenticate with SSL
        if (!$FailWithoutTrust) {
            $sslstream = new-object System.Net.Security.SslStream -ArgumentList $tcpclient.GetStream(),$false, {$true}
        } else {
            $sslstream = new-object System.Net.Security.SslStream -ArgumentList $tcpclient.GetStream(),$false
        }

        $sslstream.AuthenticateAsClient($SNIHeader)
        $cert =  [System.Security.Cryptography.X509Certificates.X509Certificate2]($sslstream.remotecertificate)

     } catch {
        throw "Failed to retrieve remote certificate from $hostname`:$port because $_"
     } finally {
        #cleanup
        if ($sslStream) {$sslstream.close()}
        if ($tcpclient) {$tcpclient.close()}        
     }    
    return $cert
}