$WebSiteName = "SiteName.API"
$FolderName = "SiteName"
$Service = "Api"
<# or write Web-Sites; Web-Services; Windows-Services #>
$Bindigs = "http/*:80:SiteName.03.Test.API.lb.ge"
<# or $Bindigs = "https/*:443:SiteName.03.Test.API.lb.ge"#>
$PoolName = $WebSiteName
$NewPath = "D:\$Service\$FolderName\Current"
$LogPath = "D:\Logs\$Service\$FolderName"
if (-not(Test-Path -Path $NewPath))
{
New-Item -Path $NewPath -ItemType directory
}
if (-not(Test-Path -Path $LogPath))
{
New-Item -Path $LogPath -ItemType directory
}
#check if the site exists
if (Test-Path $WebSiteName -pathType container)
{
return
}
#create the site
C:/Windows/System32/inetsrv/appcmd.exe add site /name:$WebSiteName /bindings:$Bindigs /physicalPath:$NewPath
C:/Windows/System32/inetsrv/appcmd.exe add apppool /name:$WebSiteName
C:/Windows/System32/inetsrv/appcmd.exe set app $PoolName/ /applicationPool:$WebSiteName
C:/Windows/System32/inetsrv/appcmd.exe start apppool /apppool.name:$WebSiteName
