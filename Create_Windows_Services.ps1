$serviceName = "LB.LMSCollectionProcessHandler"
$FolderName = "AltaSoftLMSEventHandler"
$RunFileExe ="CollectionProcessHandler.exe"
$Service = "Windows-Services"
$LogPath = "D:\Logs\$Service\$FolderName"
$NewPath = "D:\$Service\$FolderName\Current"
$running = Get-Service -display $serviceName -ErrorAction SilentlyContinue
if (-not(Test-Path -Path $NewPath))
{
    New-Item -Path $NewPath -ItemType directory
}
if (-not(Test-Path -Path $LogPath))
{
    New-Item -Path $LogPath -ItemType directory
}
If ( -not $running )
{sc.exe Create $serviceName binPath= "D:\$Service\$FolderName\Current\$RunFileExe" DisplayName= "$serviceName"}
else { $serviceName+ " is installed."}