#NEEDS TO BE RUN AS DOMAIN ADMIN

$computerName = $env:COMPUTERNAME

$sharePath = "\\192.168.128.43\it"
$sharePassword = ConvertTo-SecureString "12345678" -AsPlainText -Force
$shareCredential = New-Object System.Management.Automation.PSCredential ("misc", $sharePassword)

Write-Host "[*] Enabling BitLocker" -ForegroundColor Cyan
Enable-BitLocker -MountPoint "C:" -TpmProtector -UsedSpaceOnly

# Enables a Recovery Key (Password)
Write-Host "[*] Adding BitLocker Recovery Key" -ForegroundColor Cyan
Add-BitLockerKeyProtector -MountPoint "C:" -RecoveryPasswordProtector

# Fetches said Key
$recoveryKey = (Get-BitLockerVolume -MountPoint "C:").KeyProtector | where-object {$_.KeyProtectorType -eq 'RecoveryPassword'} | select-object -expandproperty RecoveryPassword

# Defines the file to save the Key
$fileName = "${sharePath}\Bitlocker Recovery Keys\BitlockerKey-$computerName.txt"
$fileContent = "Recovery key for ${computerName}:`n`n${recoveryKey}"

# Mounts share and saves the file there
Write-Host "[*] Mouting Network Share" -ForegroundColor Cyan
New-PSDrive -Name "NAS" -PSProvider "FileSystem" -Root $sharePath -Credential $shareCredential
Write-Host "[*] Saving Bitlocker Key" -ForegroundColor Cyan
Set-Content -Path $fileName -Value $fileContent
Write-Host "[*] Recovery key saved" -ForegroundColor Cyan

# Allows remote administration 
Write-Host "[*] Enabling Remote Management with PSRemoting" -ForegroundColor Cyan
Enable-PSRemoting

Write-Host "[*] Adding hostname to $sharePath\Hostnames.txt" -ForegroundColor Cyan
Add-Content -Path "$sharePath\Hostnames.txt" -Value $computerName

Write-Host "[*] Success!" -ForegroundColor Cyan
Pause