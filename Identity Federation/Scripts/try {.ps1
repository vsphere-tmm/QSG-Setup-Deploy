try {
    #Get-VM
    dir
}
catch {
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    Break
}