param($BuildPath, $Package)

$extDir = Join-Path $BuildPath 'extensions'
$zipFile = Join-Path $BuildPath $Package.RemoteFiles[0].ImportPath 

Expand-Archive $zipFile $extDir
Remove-Item $zipFile

$srcFolder = '{0}-{1}' -f $Package.Manifest.Metadata.id, $Package.Manifest.Metadata.Version
$srcPath = (Join-Path $extDir $srcFolder)

$moduleFolder = $Package.Manifest.Metadata.id
$modulePath = Join-Path $extDir ('{0}\{1}\*' -f $srcFolder, $moduleFolder)

Move-Item $modulePath $extDir
Remove-Item $srcPath -Recurse