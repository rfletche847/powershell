<#New-ModuleManifest $manifest
    $manifest = @{
    Path='AdminTools.psd1'
    Author='Rich Fletcher' 
    CompanyName='Rich Fletcher' 
    Copyright='(c)2016 Rich Fletcher'
    Description='Sample Module for Admin Tools'
    ModuleVersion='1.0'
    PowerShellVersion='3.0'
    RootModule='.\AdminTools.psm1'
    }
#>
function Invoke-OSShutdown {
[CmdletBinding()]
param(
    [string[]]$ComputerName=$env:COMPUTERNAME,
    [ValidateRange(0,12)]
    [int]$Arg=4,
    [string]$ErrorLog='.\ErrorLog_Invoke_OSShutdown.txt',
    [switch]$LogErrors
)

    foreach ($computer in $ComputerName) {
        try{
            Get-WmiObject -Class Win32_OperatingSystem -ComputerName $computer -EA Stop |
            Invoke-WmiMethod -Name Win32Shutdown -ArgumentList $($Arg) -EA Stop | Out-Null

            #For Win32Shutdown arguements see: https://msdn.microsoft.com/en-us/library/windows/desktop/aa394058(v=vs.85).aspx
            # Defaulted it to force log off:
            # 4 (0x4) Forced Log Off (0 + 4) - Logs the user off the computer immediately and does not notify applications that the logon session is ending. This can result in a loss of data.
            
        } catch {
            if($LogErrors) {
                $computer | Out-File $ErrorLog -Append
            }
            Write-Warning "Error contacting: $computer"
        }
    

    }

}
function Get-DiskInfo {
[CmdletBinding()]
param(
    [string[]]$ComputerName=$env:COMPUTERNAME,
    [ValidateRange(0,4)]
    [int]$DriveType=3,
    [string]$ErrorLog=".\ErrorLog_Get-Disk_Info.txt",
    [switch]$LogErrors,
    [switch]$LowFreeSpace
)

    foreach ($Computer in $ComputerName) {
    
        try {
            if($LowFreeSpace) {
                Get-WmiObject -Class Win32_LogicalDisk -Filter "DriveType=$DriveType" -ComputerName $Computer -EA Stop |
                Where-Object {$_.FreeSpace / $_.Size * 100 -lt 10}
            } else {
                Get-WmiObject -Class Win32_LogicalDisk -Filter "DriveType=$DriveType" -ComputerName $Computer -EA Stop
            }
                        
        } catch {
            if($LogErrors) {
                $computer | out-file $ErrorLog -Append
            }
            Write-Warning "Error contacting: $computer"
        }

    }
    #Unknown (0)
    #No Root Directory (1)
    #Removable Disk (2)
    #Local Disk (3)
    #Network Drive (4)
    #Compact Disc (5)
    #RAM Disk (6)
}

function Get-OSInfo {
[CmdletBinding()]
param(
    [string[]]$ComputerName=$env:COMPUTERNAME,
    [string]$ErrorLog=".\ErrorLog_Get-OSInfo.txt",
    [switch]$LogErrors
)
    foreach ($computer in $ComputerName) {
        try{
            Get-WmiObject -Class Win32_OperatingSystem -ComputerName $computer -ea Stop |
            Select-Object Version,ServicePackMajorVErsion,BuildNumber,OSArchitecture
        } catch{
            if($LogErrors){
                $computer | Out-File $ErrorLog -Append
            }
            Write-Warning "Error contacting: $computer"
        }
    }
}

