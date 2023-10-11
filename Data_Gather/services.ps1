$ServiceStat = ( Get-CimInstance -ClassName Win32_Service |
    Select-Object -Property @{n="ServiceName";e={$_.name}},
                            @{n="Status";e={$_.state}},
                            @{n="StartType";e={$_.startmode}},
                            PathName 
                            )

$ServiceStat | Format-Table -Wrap 

