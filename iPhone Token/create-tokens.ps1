#
# Bulk iPhone Token creator
# Mike Foley, mfoley@rsa.com, 781-515-6391
# RSA, the Security Division of EMC
#------------------------------------------------------------------------------
# All information, statements, and descriptions herein are offered AS IS
# only and are provided for informational purposes only. EMC Corporation
# does not guarantee the performance of, or offer a warranty of any kind,
# whether express, implied, or statutory, regarding the information herein
# or the compatibility of the information herein with EMC Corporation software
# or hardware products or other products.
#-------------------------------------------------------------------------------
# Requirements:
# Windows Powershell - Run Windows Update and you'll get it. Ships with Win7 and
# Win2008 by default
# Quest Active Directory cmdlets - Free download from 
# http://www.quest.com/powershell/activeroles-server.aspx
#-------------------------------------------------------------------------------
# SMTP Server you can send email thru. If you are using Exchange and your CORP 
# account, uncomment and point $smtpserver at a CORP Exchange server and the 
# script will use your current AD credentials to automatically log in.
#
# $smtpserver = 192.168.1.1
#
# To take advantage of the Active Directory stuff, uncomment the code below and 
# have a valid account that can browse the AD store
#
# Connect to any available domain controller with the credentials of the locally
# logged on user.
# See Help Connect-QADService -examples for more info
# Uncomment for using AD
#add-PSSnapin quest.activeroles.admanagement 
#Connect-QADService
#
# $token_location is the directory that the sdtid files are located in. 
# Current value is the same folder this script it. 
$token_location = .
$list_of_files = Get-ChildItem .  -filter "$token_location\*.sdtid"
foreach ($file in $list_of_files)
{
Write-Host "Processing $file"
#Get the username out of the token file.
[xml]$list = get-content $file
$username = $list.TKNBatch.TKN.UserLogin
Write-Host "Generating Token for $username"
# Uncomment for using AD
#$AD_user = Get-QADUser $username
#$user_email = $AD_user.email
#
#Generate the token URL and output to a variable
$token_link = .\TokenConverter.exe $file -iphone
#Write out a file on a per-user basis with the iPhone Token URL inside it.
$filename = $username + "_Token.txt"
New-Item $filename -type file -Force -Value "URL for $username is  $token_link"
#
# Uncomment for using AD and sending email.
#Send-MailMessage -SMTPserver $smtpserver -To $user_email -Subject "Your iPhone Token" -Body "Please click on the link provided $token_link to add the token to your iPhone"
}