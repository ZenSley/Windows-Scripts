$winservices = Get-Service | Select-Object *
$CIMServices = Get-CimInstance -ClassName Win32_Service | Select-Object -Property * 

$svcData = @(foreach($winservice in $winservices) {
    $imagepath = get-itempropertyvalue -path "HKLM:\SYSTEM\CurrentControlSet\Services\$($winservice.Name)\" -name ImagePath -ErrorAction SilentlyContinue
    $servicedll = get-itempropertyvalue -path "HKLM:\SYSTEM\CurrentControlSet\Services\$($winservice.Name)\Parameters" -name ServiceDLL -ErrorAction SilentlyContinue    
    $DllHash = (Get-FileHash -Path $servicedll -ErrorAction SilentlyContinue).hash
    $matchedSvc = ($CIMServices | where { $_.name -eq $winservice.servicename}) 

    $dict=@{
            "service.name" = $winservice.servicename    
            "requiredservices"= $winservice.requiredservices    
            "canpauseandcontinue" = $winservice.canpauseandcontinue    
            "canshutdown" = $winservice.canshutdown    
            "canstop" = $winservice.canstop    
            "displayname" = $winservice.displayname    
            "dependentservices" = $winservice.dependentservices    
            "servicedependedon" = $winservice.servicesdependedon    
            "servicehandle" = $winservice.servicehandle    
            "service.state" = $winservice.status    
            "service.type" = $winservice.servicetype    
            "starttype" = $winservice.starttype   
            "imagepath" = $imagepath   
            "servicedll" = $servicedll
            "servicedll.hash" = $dllHash 
            "service.ProcessID" = $matchedSvc.ProcessID
            "service.description" = $matchedSvc.Description  
            "service.installdate" = $matchedSvc.installdate

            }   
    
    New-Object -TypeName psobject -Property $dict | sort -Property Service.Name 
    })
