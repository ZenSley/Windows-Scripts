$schtasksObj = (schtasks /query /V /FO CSV | ConvertFrom-Csv | Where-Object {$_."Scheduled Task State" -eq "Enabled"})
$getSchObj = (Get-ScheduledTask -Verbose) 

$formattedTasks = @(foreach($task in $schtasksObj){
    $SchTaskMatched = ($getSchObj |  where {$_.URI -eq $task.taskname } )
    $ExePath = ([string]$SchTaskMatched.Actions.Execute).ToLower()
    if ( $ExePath -like "*%windir%*") {
        $cleanExePath = $ExePath.replace('%windir%', $env:windir)
        }elseif ($ExePath -clike "*%systemroot%*") {
        $cleanExePath = $ExePath.replace('%systemroot%', $env:SystemDrive)
        }elseif ($ExePath -like "*%programfiles%*") {
        $cleanExePath = $ExePath.replace('%programfiles%', $env:ProgramFiles)
        }elseif ($ExePath -like "*%programdata%*") {
        $cleanExePath = $ExePath.replace('%programdata%', $env:ProgramData)
        }elseif ($ExePath -like "*%programfiles(x86)%*") {
        $cleanExePath = $ExePath.replace('%programfiles(x86)%', ${env:ProgramFiles(x86)})
        }elseif ([string]::IsNullOrEmpty($ExePath)) {
        $cleanExePath = 'No Executable Provide'
        }else{
        $cleanExePath = $ExePath
        }
    $data = @{
                TaskName = $SchTaskMatched.taskname
                Status = $task.Status
                Description = $SchTaskMatched.Description
                Run_As_User = $task.'Run As User'
                Next_Run_Time = $task.'Next Run Time'   
                Last_Run_Time = $task.'Last Run Time'
                Start_Time = $task.'Start Time'
                End_Date = $task.'End Date'
                Task_to_Run = $task.'Task To Run'
                Exe_Hash = (Get-FileHash $cleanExePath -ErrorAction SilentlyContinue).hash
    } 
    New-Object -TypeName psobject -Property $data | sort -Property TaskName
}) 

$formattedTasks | Sort-Object -Property TaskName 
