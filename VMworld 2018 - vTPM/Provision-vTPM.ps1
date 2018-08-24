$VM = Get-VM -name "Windows 10 - 2"
#Check if VM has a vTPM
#Query if you want to reset the vTPM
#Get a CSR for the vTPM
# the output of Get-VTpmCSR is a string
$csrStr = Get-VTpm -VM $vm | Get-VTpmCSR -CSRType RSA
$csrStr | Out-File "c:\test.req"
$filerequest = "c:\test.req" 
#// this is for windows platform; for linux platform, just $csrStr | output-file, then use openssl to read the CSR info and generate cert
$csrObj = New-Object -ComObject X509enrollment.CX509CertificateRequestPkcs10 | $csrObj.InitializeDecode($csrStr, 6)

#Add code to submit the CSR to the MS CA and get back a cert
$enrollresult = Get-Certificate -Request $filerequest -template User 
#Take the cert and add it to the vTPM.  This will essentially re-init the TPM. All existing data will be destroyed.
#Get-VTpm -VM $vm | Set-VTpm -Certificate $certObj or -CertFilePath <the filepath>
Get-VTpm -VM $vm | Set-VTpm -Certificate $enrollresult 



<# New-VTpm -VM $vm // add a new vtpm to the VM (the VM should be in VC6.7 which has default KMScluster or the VM is already encrypted)
$csrStr = Get-VTpm -VM $vm | Get-VTpmCSR -CSRType RSA // the output of Get-VTpmCSR is a string
$csrObj = New-Object -ComObject X509enrollment.CX509CertificateRequestPkcs10 | $csrObj.InitializeDecode($csrStr, 6) // this is for windows platform; for linux platform, just $csrStr | output-file, then use openssl to read the CSR info and generate cert
<Generate a cert according to the $csrObj>
Get-VTpm -VM $vm | Set-VTpm -Certificate $certObj or -CertFilePath <the filepath>
  #>