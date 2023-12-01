$Creds = Get-Credentials
$Targets = # import target list with target hostnames or IP 

Invoke-Command -CN $targets -CR $Creds -FilePath ..\Data_Gather\autoruns.ps1 -ArgumentList (,(Get-Content ..\Data_Gather\Autoruns.txt)) | Export-Csv .\AutoRunsBaseline.csv
