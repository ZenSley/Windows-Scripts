# Define Registry Keys that will be checked 
([string[]] $autoRunKey) = Get-Content -Path ..\autoruns.txt 

$RegRun = @(foreach ($key in Get-Item -Path $autoRunKey -ErrorAction SilentlyContinue){
    $data = $key.GetValueNames() |
        Select-Object -Property @{n="Key_Location"; e={$key}},
                                @{n="Key_ValueName"; e={$_}},
                                @{n="Key_Value"; e={$key.GetValue($_)}}
    if($null -ne $data){
    [pscustomobject]$data
    }
})

$StartUpPaths = @(
    "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
    "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Startup"
    )

$StartUps = (Get-ChildItem -Path $StartUpPaths -Recurse -Force | where { $_.Name -ne "desktop.ini" } )

Write-Host "~~~~Registry Autostarts~~~~" 
$RegRun | Format-Table -Wrap

Write-Host "~~~~AutoStart Folders~~~~"
$StartUps
