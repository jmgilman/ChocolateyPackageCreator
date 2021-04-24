$packageName = 'chrome-enterprise'
$fileName = 'GoogleChromeStandaloneEnterprise64.msi'
$fileType = 'msi'
$silentArgs = '/qn'

$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$fileLocation = Join-Path $toolsDir $fileName

Install-ChocolateyInstallPackage `
    -PackageName $packageName `
    -FileType $fileType `
    -File64 $fileLocation `
    -SilentArgs $silentArgs