<#
    .DESCRIPTION
        Hashing all your drives concurrently

    .EXAMPLE
        1. PowerShell 5.1 Command Prompt (Admin) 
            "powershell -Executionpolicy Bypass -File PATH\FILENAME.ps1"
        2. Powershell 7.2.1 Command Prompt (Admin) 
            "pwsh -Executionpolicy Bypass -File PATH\FILENAME.ps1"
        
        Go to Link Below, Identify the number of files and  update range
        https://virusshare.com/hashes

    .NOTES
        Author Perkins
        Last Update 1/22/22
    
        Powershell 5 and 7.1.2
        Run as Administrator
    
    .FUNCTIONALITY
        PowerShell Language
        Active Directory
    
    .Link
        https://github.com/COD-Team
        YouTube Video https://youtu.be/4LSMP0gj1IQ
        https://youtu.be/n_Thhb3u_Jk
        https://github.com/COD-Team/HashingIOC
#>

# Define Algorithm MD5, SHA1, SHA256 (Select one of the Folling, DB is built on MD5)
$Algorithm = "MD5"
#$Algorithm = "SHA1"
#$Algorithm = "SHA256"

# List the Drives you want to HASH
$Drives = @('C:\','E:\','F:\','G:\','H:\')

# Define the extensions you want to Hash and Validate, List compiled from open sources
$Extensions = ('*.dll', '*.sys', '*.exe', '*.scr', '*.pdf', '*.vbs', '*.rtf', '*.doc', '*.xls', '*.jpeg', '*.zip', '*.html', '*.php', '*.rar', '*.htm', '*.asp', '*.jpg')

# Output File Name, ComputerName and Algorith defined above
$LogFile = "$env:computername($Algorithm).csv"

# What is the Folder Path for the Results File, Using Date-Time Folder to prevent overwriting and can be used for data integrity
$logpath = "C:\Hash\Results\$(get-date -format "yyyyMMdd-hhmmss")"
    If(!(test-path $logpath))
    {
          New-Item -ItemType Directory -Force -Path $logpath
    }

# Should not need to modify below
$i = 0
$SimultaneousJobs = 8

$HashBlock =
{
    param($Disk)
    $Results = Get-ChildItem -Path $Disk -Include $using:Extensions -Recurse | 
        Get-FileHash -Algorithm $using:Algorithm | Select-Object Hash, path 
    $Results | Export-Csv $using:logpath\$using:LogFile -Append -NoTypeInformation
}

Measure-Command {
foreach ( $Disk in $Drives) 
{
    if($i++ -lt $simultaneousJobs)
    {
        $fileNumber++
        Start-Job -ArgumentList $Disk -ScriptBlock $HashBlock | Out-Null
    }
    do
    {
        Get-Job | Receive-Job          
        get-job -State Completed | remove-job               
        $i=(get-job -state 'Running').count   
    }        
    until($i -lt $simultaneousJobs)     
}

If ($i -gt 0) 
{
    Write-Host -ForegroundColor Yellow "Waiting on $i Jobs to Complete"
}
do 
{
    $i=(get-job -state 'Running').count
    $GetDate = (Get-Date)
    Write-Host -ForegroundColor Yellow "Waiting on $i Jobs to Complete $GetDate"
    Start-Sleep -Seconds 5
}
Until ($i -eq 0)
get-job | remove-job
}