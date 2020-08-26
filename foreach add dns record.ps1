65..79 | % {
    Add-DNSServerResourceRecordA -ZoneName "CPBU.lab"  -ComputerName mgt-dc-01.cpbu.lab -Name WCP-esxi-otep-$_ -IPv4Address "10.172.212.$_" -CreatePtr -AllowUpdateAny -TimeToLive 01:00:00
    
    }
    
    Add-DNSServerResourceRecordA -ZoneName "CPBU.lab"  -ComputerName mgt-dc-01.cpbu.lab -Name WCP-CP1 -IPv4Address "10.172.212.51" -CreatePtr -AllowUpdateAny -TimeToLive 01:00:00
    Add-DNSServerResourceRecordA -ZoneName "CPBU.lab"  -ComputerName mgt-dc-01.cpbu.lab -Name WCP-CP2 -IPv4Address "10.172.212.52" -CreatePtr -AllowUpdateAny -TimeToLive 01:00:00
    Add-DNSServerResourceRecordA -ZoneName "CPBU.lab"  -ComputerName mgt-dc-01.cpbu.lab -Name WCP-CP3 -IPv4Address "10.172.212.53" -CreatePtr -AllowUpdateAny -TimeToLive 01:00:00
    Add-DNSServerResourceRecordA -ZoneName "CPBU.lab"  -ComputerName mgt-dc-01.cpbu.lab -Name WCP-CP4 -IPv4Address "10.172.212.54" -CreatePtr -AllowUpdateAny -TimeToLive 01:00:00
    Add-DNSServerResourceRecordA -ZoneName "CPBU.lab"  -ComputerName mgt-dc-01.cpbu.lab -Name WCP-CP5 -IPv4Address "10.172.212.55" -CreatePtr -AllowUpdateAny -TimeToLive 01:00:00