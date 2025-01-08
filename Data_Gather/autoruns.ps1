# Define Registry Keys that will be checked
$autoRunKey = @(
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
    "HKCU:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Run",
    "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Windows\Run",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnceEx",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunServices",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunServicesOnce",
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
    "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Run",
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce",
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnceEx",
    "HKLM:\System\CurrentControlSet\Services",
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunServices",
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunServicesOnce",
    "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components",
    "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Active Setup\Installed Components",
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\SharedTaskScheduler",
    "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\SharedTaskScheduler",
    "HKU:\*\Software\Microsoft\Windows\CurrentVersion\Run",
    "HKU:\*\Software\Microsoft\Windows\CurrentVersion\RunOnce"
)

# Collect Registry Autostarts
$RegRun = foreach ($keyPath in $autoRunKey) {
    try {
        $key = Get-Item -Path $keyPath -ErrorAction SilentlyContinue
        if ($null -ne $key) {
            $key.GetValueNames() | ForEach-Object {
                [pscustomobject]@{
                    Key_Location  = $key.PSPath
                    Key_ValueName = $_
                    Key_Value     = $key.GetValue($_)
                }
            }
        }
    } catch {
        Write-Error "Failed to process registry key: $keyPath"
    }
}

# Define Startup Paths
$StartUpPaths = @("$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Startup")

$user_list = Get-Item C:\users\* | Select-Object Name -ExpandProperty Name
foreach ($username in $user_list) {
    if ($username -notlike "*Public*") {
        $UserPath = "c:\Users\$username\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"
        if (Test-Path -path $UserPath){
            $StartUpPaths += $UserPath
            }
        }
    } 

# Collect User Startup Folder Items
$StartUps = foreach ($path in $StartUpPaths) {
    try {
        Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -ne "desktop.ini" }
    } catch {
        Write-Error "Failed to process startup folder: $path"
    }
}

# Display Results
Write-Host "~~~~ Registry Autostarts ~~~~" -ForegroundColor Cyan
$RegRun | Format-Table -AutoSize -Wrap

Write-Host "~~~~ AutoStart Folders ~~~~" -ForegroundColor Cyan
$StartUps | Format-Table FullName, CreationTime -AutoSize
