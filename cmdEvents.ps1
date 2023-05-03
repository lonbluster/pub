$enc= "utf8"       ;       if (!($hours_)) { $hours= -48 } else {$hours=-$hours_}        ;       $date=(get-date).ToString("MMMMdd_'H'HH'.'mm")       ;       $csv= "$(hostname)_eventsTo$date.csv"       ;       Get-WinEvent -ErrorAction Continue -WarningAction Continue -FilterHashtable @{ logname='system','application'; level=1,2,3 ; StartTime=[datetime]::now.AddHours($hours) ; EndTime=[datetime]::now }       |       Select-Object TimeCreated,LevelDisplayName,LogName,id,ProviderName,Message       |       Export-Csv -Encoding $enc -Path .\$csv -NoTypeInformation

$User = "andrea.gasparetto@informaticall.it"
$PWord = ConvertTo-SecureString -String "ZWgEDdnqggV7!" -AsPlainText -Force
$Cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $PWord

$to = 'andrea.gasparetto@informaticall.it'
#PRIVATE
$errorEvents = Out-String -InputObject $(Get-WinEvent -ErrorAction Continue -WarningAction Continue -MaxEvents 5 -FilterHashtable @{ logname='system','application'; level=1,2 } | Format-List id,TimeCreated,Message)
$model = (Get-CimInstance -ClassName Win32_ComputerSystem).model
$ram = Out-String -InputObject $(Get-CimInstance -ClassName Win32_PhysicalMemory | Format-List Devicelocator, Manufacturer, Speed, Capacity, BankLabel, PartNumber)
$diskspace= Out-String -InputObject $(Get-CimInstance -ClassName Win32_LogicalDisk | Select-Object -Property DeviceID,@{'Name' = 'Size (GB)'; Expression= {[int]($_.size / 1GB) }},@{'Name' = 'Free (GB)'; Expression= { [int]($_.Freespace / 1GB) }})
$uptime= ([math]::Round(((get-date) - (gcim Win32_OperatingSystem).LastBootUpTime).totaldays/1,2))
$users= Out-String -InputObject $(Get-ChildItem C:\Users)
$body = @{Body = " Model: $model `n Giorni Uptime: $uptime `n $diskspace `n $ram `n $users `n Attached last $hours hours of logs... `n -------------------  Last 5 Errors Only :  `n  $errorEvents "}
$mailParams = @{
        SmtpServer                 = 'smtps.aruba.it'
        Port                       = '587'
        UseSSL                     = $true 
        Credential                 = $Cred
        From                       = $to
        To                         = $to
        Encoding                    = "$enc"
        Subject                    = "$(([System.Net.Dns]::GetHostEntry($env:computerName)).hostname) - $($(get-date).ToString("HH':'mm")) -EVENTS"
        # DeliveryNotificationOption = 'OnFailure', 'OnSuccess'
        Attachment                   = $csv
    } #end mail param

[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { return $true }

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 #required for sending email
Send-MailMessage @mailParams @body
Start-Sleep -s 3
Remove-Item $csv
