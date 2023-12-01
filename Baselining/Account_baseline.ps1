$Creds = Get-Credentials
$Targets = # import target list with target hostnames or IP 

Invoke-Command -CN $targets -CR $Creds -Filepath ..\Data_Gather\Accounts.ps1 | Export-Csv .\accountsBaseline.csv
