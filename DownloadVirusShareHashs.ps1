
<#
    .DESCRIPTION
        Downloads all the hash files from virusshare to $DownloadPath

    .EXAMPLE
        1. PowerShell 5.1 Command Prompt (Admin) 
            "powershell -Executionpolicy Bypass -File PATH\FILENAME.ps1"
        2. Powershell 7.2.1 Command Prompt (Admin) 
            "pwsh -Executionpolicy Bypass -File PATH\FILENAME.ps1"
        
        Go to Link Below, Identify the number of files and  update range
        https://virusshare.com/hashes

        Update Download Path

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

# Update Download Path where the Files will Download
$DownloadPath = "C:\Hash\Temp\VirusShare"

# Update Range to the last Number identified from the website. 
$range = 0..404

$client = new-object System.Net.WebClient

# If Download Path does not exist, it will create it
If(-Not(test-path $DownloadPath))
    {
            New-Item -ItemType Directory -Force -Path $DownloadPath
    }

foreach ($i in $range)
{
    $iFormatted = ('{0:d5}' -f $i)
    If(-Not(test-path "$DownloadPath\VirusShare_$iFormatted.md5"))
    {
        $client.DownloadFile("https://virusshare.com/hashfiles/VirusShare_$iFormatted.md5","$DownloadPath\VirusShare_$iFormatted.md5")
        Write-Host "File Downloaded $DownloadPath\VirusShare_$iFormatted.md5"         
    }
    else {
        Write-Host "$DownloadPath\VirusShare_$iFormatted.md5 Exists Not Downloaded" 
    }
}

If(-Not(test-path "$DownloadPath\unpacked_hashes.md5"))
    {
        Write-Host "File Downloading $DownloadPath\Unpacked_Hashes.md5 Large File"
        $client.DownloadFile("https://virusshare.com/hashfiles/unpacked_hashes.md5","$DownloadPath\unpacked_hashes.md5")        
    }
    else {
        Write-Host "$DownloadPath\unpacked_hashes.md5 Exists Not Downloaded" 
    }


