#Uses Get-CimInstance to pull processes, PID, Path, CmdLine, PPID, & SHA256 for the executable.  

$procs = Get-CimInstance -ClassName Win32_Process   |
    Select-Object -Property ProcessName,
                            Handle,
                            Handles,
                            CreationDate,
                            ExecutablePath,
                            CommandLine, 
                            ProcessID,
                            ParentProcessID,
                            @{n="ExeHash"; e={(Get-FileHash -Path $_.Executablepath).hash}}
                            
$procs 
