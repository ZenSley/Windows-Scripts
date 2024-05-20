$netConx = Get-NetTCPConnection | 
    Select-Object LocalAddress,
                  LocalPort,
                  RemoteAddress,
                  RemotePort,
                  State,
                  OwningProcess,
                  @{N= 'ProcessName'; E= {(Get-WmiObject Win32_Process -filter "ProcessId = $($PSItem.OwningProcess)").Name}},
                  @{N='ExePath'; E= {(Get-WmiObject Win32_Process -filter "ProcessId = $($PSItem.OwningProcess)").path}},
                  @{N='cmdline';E= {(Get-WmiObject Win32_Process -filter "ProcessId = $($PSItem.OwningProcess)").commandline}},
                  @{N='ParentPID';E= {(Get-WmiObject Win32_Process -filter "ProcessId = $($PSItem.OwningProcess)").ParentProcessId}}
