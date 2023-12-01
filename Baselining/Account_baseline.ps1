$Creds = Get-Credentials
$Targets = # import target list with target hostnames or IP 

Invoke-Command -CN $targets -CR $Creds -FilePath ..\Data_Gather\accounts.ps1 | Export-Csv .\AccountsBaseline.csv
