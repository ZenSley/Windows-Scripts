# Pull user accounts. Displays name, status, pw pol, and SID 
$accts = (Get-CimInstance -ClassName Win32_UserAccount) 
$accts | Select-Object -Property Name, Disabled, PasswordRequired, SID
