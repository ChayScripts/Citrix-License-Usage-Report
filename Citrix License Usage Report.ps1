Start-Transcript -Path C:\Temp\LicenseScriptLogs\Logs\CitrixLicenseScriptLogs-$(Get-Date -Format yyyyMMdd-HHmm).txt -NoClobber 
function Get-CtxLicStats { 
param ( 
[string]$computername = $env:computername, 
[string]$LogLocation 
) 
$Runtime = Get-Date -Format yyyyMMdd-HHmm 
$Time = Get-Date -Format G 
$Today = Get-Date 

# license status 
$LicenseUsage = New-Object -TypeName psobject 
$InuseTotal = (Get-WmiObject -class "Citrix_GT_License_Pool" -Namespace "root\CitrixLicensing" -ComputerName $computername | ? {$_.PLD -eq 'MPS_STD_CCU'}  | Measure-Object -Property InUseCount -sum) 
$PooledAvailableTotal = (Get-WmiObject -class "Citrix_GT_License_Pool" -Namespace "root\CitrixLicensing" -ComputerName $computername | ? {$_.PLD -eq 'MPS_STD_CCU'}  | Measure-Object -Property PooledAvailable -sum) 
$CountTotal = (Get-WmiObject -class "Citrix_GT_License_Pool" -Namespace "root\CitrixLicensing" -ComputerName $computername | ? {$_.PLD -eq 'MPS_STD_CCU'}  | Measure-Object -Property Count -sum) 
$LicensingData = Get-WmiObject -class "Citrix_GT_License_Pool" -Namespace "root\CitrixLicensing" -ComputerName $computername | ? {$_.PLD -eq 'MPS_STD_CCU'} 

Add-Member -InputObject $LicenseUsage -MemberType NoteProperty -Name "Date" -Value $Time 
Add-Member -InputObject $LicenseUsage -MemberType NoteProperty -Name "Total Count" -Value $CountTotal.sum 
Add-Member -InputObject $LicenseUsage -MemberType NoteProperty -Name "In Use Count" -Value $InuseTotal.sum 
Add-Member -InputObject $LicenseUsage -MemberType NoteProperty -Name "Available Licenses" -Value $PooledAvailableTotal.sum 
Add-Member -InputObject $LicenseUsage -MemberType NoteProperty -Name "Available Percent" -Value ("{0:N2}" -f (($PooledAvailableTotal.sum/$CountTotal.sum)*100)) 
Add-Member -InputObject $LicenseUsage -MemberType NoteProperty -Name "Percent in use" -Value ("{0:N2}" -f (($InuseTotal.Sum/$CountTotal.sum)*100)) 
Add-Member -InputObject $LicenseUsage -MemberType NoteProperty -Name "Product Name" -Value ( "XenApp (Presentation Server) Standard|Concurrent User" ) 

$a = "<style>" 
$a = $a + "TABLE{border-width: 2px;border-style: solid;border-color: black;border-collapse: collapse;}" 
$a = $a + "TH{border-width: 1px;padding: 10px;border-style: solid;border-color: black;}" 
$a = $a + "TD{border-width: 1px;padding: 10px;border-style: solid;border-color: black;}" 
$a = $a + "</style>" 

$LicenseUsage | ConvertTo-HTML -head $a -Body "<br />License Utilization report as on $Time<br /><br />"  | Out-File "$LogLocation\CitrixLicenseUsage-$Runtime.html" 
$LicenseUsage | export-csv "$LogLocation\CitrixLicenseUsage.csv" -NoTypeInformation -Append 
$availablepercent = ("{0:N2}" -f (($PooledAvailableTotal.sum/$CountTotal.sum)*100)) 

if ($availablepercent -le 10) { 
$EmailTo = "" 
$Body = "Hi, "  + (Get-Content -Path "$loglocation\CitrixLicenseUsage-$Runtime.html" ) + " <br /><br />" + "<H3>Note: Only 10% licenses are available. </H3>" + " <br /><br />" + "Thanks, <br /> Citrix Admin .<br /><br />" 
Send-MailMessage -From "AutomatedScript@company.com" -To $EmailTo -Subject "Citrix License Utilization as on: $Today" -BodyAsHtml "$Body" -SmtpServer SMTP.company.com -Priority High 
} 
} 
Get-CtxLicStats -computername CitrixLicenseServerName -LogLocation C:\Temp\LicenseScriptLogs 
Stop-Transcript 
