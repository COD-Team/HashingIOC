Video YouTube https://youtu.be/n_Thhb3u_Jk
github https://github.com/COD-Team/HashingIOC


For the purpose of this series, all the scripts are using c:\Hash 
The files from github, should be placed in c:\Hash\Powershell folder. 
I have not testing executing from other locations. 
Testing in Powershell 5.1 and 7.2.1 - Tried to include commands for both

## Create your MasterHashList from known VirusShare.com
This Script downloads all the Hash files from VirusShare

https://virusshare.com/hashes
	From link above, what is the largest file Number

edit DownloadVirusShareHashs.ps1 Update $DownloadPath and $Range (largest number from the site above)
	$DownloadPath = "C:\Hash\Temp\VirusShare"
	$range = 0..404

Save and Execute (Pending Network Speed, just a few minutes)
powershell -executionpolicy bypass -file DownloadVirusShareHashs.ps1
pwsh -executionpolicy bypass -file DownloadVirusShareHashs.ps1

## Merge all the hash files
This script merges all the files you just downloaded in the previous set

edit MergeHashFiles.ps1, Update $HashPath, $LogFile and Range (Same number used above)
	$HashPath = "C:\Hash\Temp\VirusShare"
	$LogFile = "Master.txt"
	$range = 0..403

Save and Execute (Average about 10 minutes)
powershell -executionpolicy bypass -file MergeHashFiles.ps1
pwsh -executionpolicy bypass -file MergeHashFiles.ps1

NOTE: while this is running, open new Command Prompt and start Hashing your computer with steps below

## Create Hash of your Computer
edit CreateLocalHashAllDrives.ps1 Adjust variables for your environment
	$Algorithm = "MD5"
	$Drives = @('C:\','E:\','F:\','G:\','H:\') 
	$Extensions = ('*.dll', '*.sys', '*.exe', '*.scr', '*.pdf', '*.vbs', '*.rtf', '*.doc', '*.xls', '*.jpeg', '*.zip', '*.html', '*.php', '*.rar', '*.htm', '*.asp', '*.jpg')
	$LogFile = "$env:computername($Algorithm).csv"
	$logpath = "C:\Hash\Results\$(get-date -format "yyyyMMdd-hhmmss")"

Save and execute (Average 10 minutes across all 5 drives for the extensions listed)
powershell -executionpolicy bypass -file CreateLocalHashAllDrives.ps1
pwsh -executionpolicy bypass -file CreateLocalHashAllDrives.ps1

NOTE: while this is running, open new Command Prompt and start loading SQLite with steps below

## Download SQLite
This will download to the $DownloadPath, unzip, move the uncompressed .exe files into $HashPath\SQLite folder
Script also creates a two folders (.\db, .\scripts) and lastly creates the database
Check https://www.sqlite.org/download.html for the latest, you only need the sqlite-tools-win32-x86-XXXXXXX.zip 
for this project under Precomplied Binaries for Windows.

Edit DownloadSQLite.ps1
	$DownloadPath = "C:\Hash\Temp"
	$HashPath = "C:\Hash"
	$Webpath = "https://www.sqlite.org/2022/sqlite-tools-win32-x86-3370200.zip"
	$FileName = "sqlite-tools-win32-x86-3370200.zip"
	$SQLPath = "SQLite"

Save and execute
powershell -executionpolicy bypass -file DownloadSQLite.ps1
pwsh -executionpolicy bypass -file DownloadSQLite.ps1

A new Command Window will open, see Setup SQLite section below. 

## Setup SQLite
You can copy and paste each command into the SQLite Window, .tables should not return anything
the first time you run, the .read command will build the DB for you with all the necessary tables and views
.tables
.read c:/hash/sqlite/scripts/createtablesindexs.sql
.tables
.indexes
.quit

## Import the Import of the Master.txt file we just created (MergeHashFiles.ps1 must be completed)
From Command Prompt, execute the following to open SQLite
C:\Hash\SQLite\sqlite3.exe C:\Hash\SQLite\db\HashMaster.db

This command will set to import mode for csv files
.timer on
.mode csv
.separator ,
.import C:/hash/temp/virusshare/Master1.txt tempmaster
.import C:/hash/temp/virusshare/Master2.txt tempmaster
Select count(*) from tempmaster;
Select * from tempmaster limit 10;

Insert or Ignore into mastermd5 (hash, source, cddid) Select lower(hash), "VirusShare", "" from tempmaster;
Select * from mastermd5 limit 10;
delete from tempmaster;

.import C:/hash/temp/virusshare/virusshare_00404.md5 tempmaster
Select count(*) from tempmaster;
Select * from tempmaster limit 10;

MD5
Insert or Ignore into mastermd5 (hash, source, cddid) Select lower(hash), "", "" from tempmaster;
SHA1
Insert or Ignore into masterSHA1 (hash, source, cddid) Select lower(hash), "", "" from tempmaster;
SHA5
Insert or Ignore into masterSHA5 (hash, source, cddid) Select lower(hash), "", "" from tempmaster;

C:\Hash\SQLite\sqlite3.exe C:\Hash\SQLite\db\HashMaster.db VACUUM

## Import Local Computer Hash values
Get the path from the CreateLocalHashAllDrives
.mode csv
.separator ,
.import C:/Hash/Results/20220121-102317/DESKTOP-RFH175E(MD5).csv templocal

Select count(*) from templocal;

Insert or Ignore into importedmd5 (hash, path) Select lower(hash), path from templocal;
Select count(*) from importedmd5;

Select * from v_md5;

Select hash, count(hash) from templocal group by hash having count(*) > 100 order by count(*);
Select count(distinct hash) from templocal;
Select hash, path from templocal where hash = "605611DACA7116880DBD439D19016D23";

## Export Results.... 
.headers on
.mode csv
.output c:/hash/results/ResultsMD5.csv
select * from v_md5;
.output stdout

Open File, Copy Hashs
Insert into https://hash.cymru.com/

# Cleanup for Next Job
Delete from importedmd5;
delete from importedsha1;
delete from importedsha5;
delete from templocal;
delete from tempmaster;
.quit

C:\Hash\SQLite\sqlite3.exe C:\Hash\SQLite\db\HashMaster.db VACUUM

### End of Instruction, Below is additional

https://virusshare.com/hashes
https://bazaar.abuse.ch/export/
https://a4lg.com/downloads/vxshare/index.en.html
https://hash.cymru.com/
https://www.virustotal.com/gui/home/upload

MASTERMD5 = Master MD5 Hash Table
MASTERSHA1 = Master SHA1 Hash Table
MASTERSHA5 = Master SHA5 Hash Table
Importedmd5 = Will Import from tempmaster Table
ImportedSHA1 = Will Import from tempmaster Table
ImportedSHA5 = Will Import from tempmaster Table
tempmaster = Import master Hash Files here so we can clean up before importing into master
templocal = Import local hash with path here so we can clea before importing
v_md5 = This is a view to compare Hash between MD5 and Importmd5 tables, returns positive hits
v_sha1 = This is a view to compare Hash between SHA1 and ImportSHA1 tables, returns positive hits
v_sha5 = This is a view to compare Hash between SHA5 and ImportSHA5 tables, returns positive hits

Custom Updating Master, Update Table
Insert or Ignore into mastermd5 (hash, source, cddid) Select lower("00F538C3D410822E241486CA061A57EE"), "COD", "1234" from tempmaster;


Select name from sqlite_master where type='table';
