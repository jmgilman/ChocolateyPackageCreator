param($BuildPath)

$extPath = Join-Path $BuildPath 'extensions'
$extFile = Join-Path $extPath 'cpc.zip'

Expand-Archive $extFile $extPath
Remove-Item $extFile

Move-Item (Join-Path $extPath 'ChocolateyPackageManager-master/ChocolateyPackageCreator/*') $extPath
Remove-Item (Join-Path $extPath 'ChocolateyPackageManager-master') -Recurse