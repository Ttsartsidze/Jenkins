# Get fixed drive info for specified server

param([string] $Server, [string] $warn, [string] $crit)

$alertcrit = 0
$alertwarn = 0  
$error.clear()
$disks = Get-WmiObject -ComputerName $Server -Class Win32_LogicalDisk -Filter "DriveType = 3";
foreach($disk in $disks)
{
	$deviceID = $disk.DeviceID;
	[float]$size = $disk.Size;
	[float]$freespace = $disk.FreeSpace;

	$percentFree = [Math]::Round(($freespace / $size) * 100, 2);
	$sizeGB = [Math]::Round($size / 1073741824, 2);
	$freeSpaceGB = [Math]::Round($freespace / 1073741824, 2);
	if($percentFree -lt $crit -and $freeSpaceGB -lt 5)
	{
		Write-Host "CRITICAL $deviceID = $percentFree % Free! | $deviceID=$percentFree%;;;0;";
		$alertcrit = 1
	}
	elseif($percentFree -lt $warn -and $freeSpaceGB -lt 10)
	{
        #Attempt to clean Disk
		$oldTime = [int]7 # Specifies min age of a files to remove
		# Create array containing all user profile folders
		$colProfiles = Get-ChildItem "\\$server\c$\Users\" -Name -force -ErrorAction SilentlyContinue
		$colProfiles = $colProfiles -ne "All Users"
		$colProfiles = $colProfiles -ne "Default"
		$colProfiles = $colProfiles -ne "Default User"

		# Removes temporary files from each user profile folder
		ForEach ( $objProfile in $colProfiles ) {
			# Remove all files and folders in user's Temp folder. The -force switch on Get-ChildItem gets hidden directories as well.
			Get-ChildItem "\\$server\c$\Users\$objProfile\AppData\Local\Temp\*" -recurse -force -ErrorAction SilentlyContinue | WHERE {($_.CreationTime -le $(Get-Date).AddDays(-$oldTime))} | remove-item -force -recurse -ErrorAction SilentlyContinue
			# Remove all files and folders in user's Temporary Internet Files. 
			Get-ChildItem "\\$server\c$\Users\$objProfile\AppData\Local\Microsoft\Windows\Temporary Internet Files\*" -recurse -force -ErrorAction SilentlyContinue | WHERE {($_.CreationTime -le $(Get-Date).AddDays(-$oldTime))} | remove-item -force -recurse -ErrorAction SilentlyContinue
		}
		# Cleans Windows Temp directory
		Get-ChildItem "\\$server\c$\Windows\Temp\*" -recurse -force -ErrorAction SilentlyContinue | WHERE {($_.CreationTime -le $(Get-Date).AddDays(-$oldTime))} | remove-item -force -recurse -ErrorAction SilentlyContinue

		# Cleans Standard Temp directory
		Get-ChildItem "\\$server\c$\Temp\*" -recurse -force -ErrorAction SilentlyContinue | WHERE {($_.CreationTime -le $(Get-Date).AddDays(-$oldTime))} | remove-item -force -recurse -ErrorAction SilentlyContinue

		# Cleans IIS Logs if applicable
		Get-ChildItem "\\$server\c$\inetpub\logs\LogFiles\*" -recurse -force -ErrorAction SilentlyContinue | WHERE {($_.CreationTime -le $(Get-Date).AddDays(-$oldTime))} | remove-item -force -recurse -ErrorAction SilentlyContinue

		# Empties the Recycle Bin
		Get-ChildItem "\\$server\c$\`$RECYCLE.BIN\*" -recurse -force -ErrorAction SilentlyContinue | WHERE {($_.CreationTime -le $(Get-Date).AddDays(-$oldTime))} | remove-item -force -recurse -ErrorAction SilentlyContinue
		
		# Now we notify as per normal 
		Write-Host  "WARNING $deviceID = $percentFree % Free! | $deviceID=$percentFree%;;;0;";
		$alertwarn = 1
	}
	Else
	{
		Write-Host "$deviceID=$percentFree% Free| $deviceID=$percentFree%;;;0;"
	}
}
if ($alertcrit -gt 0) 
{
exit 2
}
elseif ($alertwarn -gt 0)
{
exit 1
}
elseif ($error.Count -gt 0)
{
Write-Output $_;
  $_="";
  exit 3;
}
else 
{
exit 0
}

