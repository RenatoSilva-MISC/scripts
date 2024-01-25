#Mount fileshare and install drivers
$sharePassword = ConvertTo-SecureString "12345678" -AsPlainText -Force
$shareCredential = New-Object System.Management.Automation.PSCredential ("misc", $sharePassword)
New-PSDrive -Name "NAS" -PSProvider "FileSystem" -Root \\192.168.128.43\it -Credential $shareCredential
pnputil.exe /add-driver "\\192.168.128.43\it\Drivers\Brother LC8900CDW\gdi\BRPRC16A.INF"
Add-PrinterDriver -Name "Brother MFC-L8900CDW series"

# This line only works when ran as admin
$printersRemove = Get-Printer | Where-Object { $_.Name -like "Brother*" } | Select-Object -ExpandProperty Name
Remove-Printer -Name $printersRemove


Add-PrinterPort -Name 192.168.131.1 -PrinterHostAddress 192.168.131.1
Add-PrinterPort -Name 192.168.131.2 -PrinterHostAddress 192.168.131.2


Add-Printer -DriverName "Brother MFC-L8900CDW series" -Name "Brother 1" -PortName 192.168.131.1
Add-Printer -DriverName "Brother MFC-L8900CDW series" -Name "Brother 2" -PortName 192.168.131.2
