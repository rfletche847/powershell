<#
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
    New-ModuleManifest @manifest
#>
function Invoke-OSShutdown {
<#
	.SYNOPSIS
		This function provides a way to invoke a local or remote computer to logoff/shutdown/etc via WMI.
	.PARAMETER Computername
		The name of the computer to invoke action on. Defaults to local machine
	.PARAMETER Arg
		Win32Shutdown arguments, defaulted to force logoff (4) see https://msdn.microsoft.com/en-us/library/windows/desktop/aa394058(v=vs.85).aspx
	.PARAMETER ErrorLog
		The path to where errors should be captured, requires LogErrors to be set to true.
	.PARAMETER LogErrors
		Logs the errors when set.
	#>
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
<#
	.SYNOPSIS
		This function provides a way to pull drive information from alocal or remote computer.
	.PARAMETER Computername
		The name of the computer to invoke action on. Defaults to local machine
	.PARAMETER DriveType
		Win32_LogicalDisk DriveType, defaulted to local disk (3) see https://msdn.microsoft.com/en-us/library/windows/desktop/aa394173(v=vs.85).aspx
	.PARAMETER ErrorLog
		The path to where errors should be captured, requires LogErrors to be set to true.
	.PARAMETER LogErrors
		Logs the errors when set to true.
    .PARAMETER LowFreeSpace
        Shows only information for drives lower than 10% is set.
	#>
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
<#
	.SYNOPSIS
		This function provides a way to pull Operating System information from a local or remote computer via WMI.
	.PARAMETER Computername
		The name of the computer to invoke action on. Defaults to local machine
	.PARAMETER ErrorLog
		The path to where errors should be captured, requires LogErrors to be set to true.
	.PARAMETER LogErrors
		Logs the errors when set to true.
	#>
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

