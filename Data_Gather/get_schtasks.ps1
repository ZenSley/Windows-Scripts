#Queries enabled scheduled tasks, combining functions from schtasks.exe and the Get-ScheduledTask PS cmdlet to provide task information and a hash of called task executable.

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
        $cleanExePath = 'No Executable Provided'
        }else{
        $cleanExePath = $ExePath
        }
    $data = @{
                'Task.Name' = $SchTaskMatched.taskname
                'Task.Path' = $SchTaskMatched.TaskPath
                'Task.Status' = $task.Status
                'Task.State' = $task.'Scheduled Task State'
                'Task.Author' = $task.Author 
                'Task.Description' = $SchTaskMatched.Description
                'Task.TriggerType' = $task.'Schedule Type'
                'Task.RepeatInterval' = $task.'Repeat: Every'
                'Task.Run_As_User' = $task.'Run As User'
                'Task.Next_Run_Time' = $task.'Next Run Time'   
                'Task.Last_Run_Time' = $task.'Last Run Time'
                'Task.StartTime' = $task.'Start Time'
                'Task.EndDate' = $task.'End Date'
                'Task.Task_to_Run' = $task.'Task To Run'
                'Task.ExecutableSHA256' = (Get-FileHash $cleanExePath -Algorithm SHA256 -ErrorAction SilentlyContinue).hash
                'Task.ExecutableSHA1' = (Get-FileHash $cleanExePath -Algorithm SHA1 -ErrorAction SilentlyContinue).hash
                'Task.ExecutableMD5' = (Get-FileHash $cleanExePath -Algorithm MD5 -ErrorAction SilentlyContinue).hash
                
    } 
    New-Object -TypeName psobject -Property $data | sort -Property TaskName
}) 

#$formattedTasks | Sort-Object -Property TaskName 


