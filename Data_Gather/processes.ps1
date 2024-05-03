#Uses Get-CimInstance to pull processes, PID, Path, CmdLine, PPID, & SHA256 for the executable.  

$procs = Get-CimInstance -ClassName Win32_Process   |
    Select-Object -Property ProcessName,
                            ProcessID,
                            Path,
                            CommandLine,
                            ParentProcessID,
                            CreationDate,
                            @{n="Hash"; e={(Get-FileHash -Path $_.path).hash}}
