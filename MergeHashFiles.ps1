<#
    .DESCRIPTION
        Script will combine all the downloaded hash files into two files. 
        There are a few known issues with large files and breaking into 2 files
        decreased my processing time in half, I tried 4 and only gained another 10%, so two is a good number
        $SimultaneousJobs Default = 8, My box would not handle 16 before receiving errors, lot of data. My VM, set to 4

    .EXAMPLE
        1. PowerShell 5.1 Command Prompt (Admin) 
            "powershell -Executionpolicy Bypass -File PATH\FILENAME.ps1"
        2. Powershell 7.2.1 Command Prompt (Admin) 
            "pwsh -Executionpolicy Bypass -File PATH\FILENAME.ps1"
    
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

$HashPath = "C:\Hash\Temp\VirusShare"
$range = 0..403

$i = 0
$SimultaneousJobs = 8

If (Test-Path $HashPath\Master1.txt) {Remove-Item $HashPath\Master1.txt}
If (Test-Path $HashPath\Master2.txt) {Remove-Item $HashPath\Master2.txt}

$HashBlock = 
{
    $iFormatted = ('{0:d5}' -f $using:File)
    Write-Host -ForegroundColor Green "Reading File $using:HashPath\VirusShare_$iFormatted.md5"
    $RawContent = Get-Content -Path "$using:HashPath\VirusShare_$iFormatted.md5" | Select-Object -Skip 6 
    Write-Host -ForegroundColor Yellow "Processing File $using:HashPath\VirusShare_$iFormatted.md5"

    if ($using:File % 2 -eq 0)
    {
        $done = $false
            while(-not $done)
            {
                try{ $RawContent | Out-File -FilePath $using:HashPath\Master1.txt -Append -Encoding Ascii -ea Stop}
                catch { Start-Sleep 1; continue }
                $done = $true
                Write-Host -ForegroundColor Red "Compeleted File $using:HashPath\VirusShare_$iFormatted.md5"
            }
    }
    else 
    {
        $done = $false
            while(-not $done)
            {
                try{ $RawContent | Out-File -FilePath $using:HashPath\Master2.txt -Append -Encoding Ascii -ea Stop}
                catch { Start-Sleep 1; continue }
                $done = $true
                Write-Host -ForegroundColor Red "Compeleted File $using:HashPath\VirusShare_$iFormatted.md5"
            }        
    }
}

Measure-Command {
foreach ($File in $range)
{
    $iFormatted1 = ('{0:d5}' -f $File)
    if($i++ -lt $simultaneousJobs)
    {        
        Start-Job -ArgumentList $File -ScriptBlock $HashBlock | Out-Null
        Write-Host -ForegroundColor Cyan "Starting Job File $HashPath\VirusShare_$iFormatted1.md5"
        Start-Sleep 1
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
    Write-Host -ForegroundColor Yellow "Waiting on $i Jobs to complete"
}
do 
{
    $i=(get-job -state 'Running').count
    Write-Host -ForegroundColor Yellow "Waiting on $i Jobs to complete"
    Start-Sleep -Seconds 5
}
Until ($i -eq 0)
get-job | remove-job
}
