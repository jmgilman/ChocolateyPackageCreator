param($BuildPath, $Package)

$toolsDir = Join-Path $BuildPath 'tools'
$chromeDir = Join-Path $toolsDir 'chrome'
$zipFile = Join-Path $BuildPath $Package.RemoteFiles[0].ImportPath 

New-Item -ItemType Directory $chromeDir
Expand-Archive $zipFile $chromeDir

Copy-Item (Join-Path $chromeDir 'installers/GoogleChromeStandaloneEnterprise64.msi') $toolsDir
Remove-Item $chromeDir -Recurse -Force
Remove-Item $zipFile