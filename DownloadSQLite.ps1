<#
    .DESCRIPTION
        Script will Download SQLite to the the $HASHPATH\Temp folder, uncompress, move files to $HASHPATH then delete
        Copies CreatTeablesIndexs.sql to $HASHPATH\$SQLPath\scripts
        Opens New Command Prompt, creates new Database in $HashPath\$SQLPath\db\HashMaster.db
        https://www.sqlite.org/download.html
        

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


$DownloadPath = "C:\Hash\Temp"
$HashPath = "C:\Hash"
$SQLPath = "SQLite"
$Webpath = "https://www.sqlite.org/2022/sqlite-tools-win32-x86-3370200.zip"
$FileName = "sqlite-tools-win32-x86-3370200.zip"

$client = new-object System.Net.WebClient

# Creates the Download Path
If(-Not(test-path $DownloadPath))
    {
            New-Item -ItemType Directory -Force -Path $DownloadPath
    }

# Check is the File has already been Downloaded, of so it will not download
If(-Not(test-path "$DownloadPath\$FileName"))
{
    $client.DownloadFile("$WebPath","$DownloadPath\$FileName")
    Write-Host -ForegroundColor Green "File Downloaded $DownloadPath\$FileName"                 
}
else 
{
    Write-Host -ForegroundColor Yellow "File Exists and Not Downloaded $DownloadPath\$FileName" 
}

If(-Not(test-path $HashPath\$SQLPath))
{
    New-Item -ItemType Directory -Force -Path $HashPath\$SQLPath
    New-Item -ItemType Directory -Force -Path $HashPath\$SQLPath\scripts
    New-Item -ItemType Directory -Force -Path $HashPath\$SQLPath\db
    Write-Host -ForegroundColor Green "Created Folder $HashPath\$SQLPath"
    Expand-Archive -LiteralPath $DownloadPath\$FileName -DestinationPath $DownloadPath -Force
    Get-ChildItem -Path "$DownloadPath\*.exe" -Recurse | Move-Item -Destination "$HashPath\$SQLPath"
    Get-ChildItem -Path "$HashPath\powershell\*.sql" -Recurse | Copy-Item -Destination "$HashPath\$SQLPath\scripts"
    Remove-Item $DownloadPath\* -include sqlite*
}

 start-process -FilePath "$HashPath\$SQLPath\sqlite3.exe" -ArgumentList "$HashPath\$SQLPath\db\HashMaster.db"
    