Set-ExecutionPolicy -ExecutionPolicy bypass -Force
$enc= "utf8"       ;       if (!($hours_)) { $hours= -24 } else {$hours=-$hours_}        ;       $date=(get-date).ToString("MMMMdd_'H'HH'.'mm")       ;       $csv= "$(hostname)_eventsTo$date.csv"       ;       Get-WinEvent -ErrorAction Continue -WarningAction Continue -FilterHashtable @{ logname='system','application'; level=1,2,3 ; StartTime=[datetime]::now.AddHours($hours) ; EndTime=[datetime]::now }       |       Select-Object TimeCreated,LevelDisplayName,LogName,id,ProviderName,Message       |       Export-Csv -Encoding $enc -Path .\$csv -NoTypeInformation

$User = "andrea.gasparetto@informaticall.it"
$PWord = ConvertTo-SecureString -String "ZWgEDdnqggV7!" -AsPlainText -Force
$Cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $PWord

$to = 'andrea.gasparetto@informaticall.it'
#PRIVATE
$body = @{Body = "Attached last $hours hours of logs..."}
$mailParams = @{
        SmtpServer                 = 'smtps.aruba.it'
        Port                       = '587'
        UseSSL                     = $true 
        Credential                 = $Cred
        From                       = $to
        To                         = $to
        Encoding                    = "$enc"
        Subject                    = "$(hostname) - server time $($(get-date).ToString("HH':'mm")) -EVENTS"
        # DeliveryNotificationOption = 'OnFailure', 'OnSuccess'
        Attachment                   = $csv
    } #end mail param

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 #required for sending email
    Send-MailMessage @mailParams @body
