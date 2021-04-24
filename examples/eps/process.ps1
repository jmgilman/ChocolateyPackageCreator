param($BuildPath)

$extDir = Join-Path $BuildPath 'extensions'
$zipFile = Join-Path $extDir 'eps.zip'

Expand-Archive $zipFile $extDir
Remove-Item $zipFile

Move-Item (Join-Path $extDir 'eps-1.0.0\EPS\*') $extDir
Remove-Item (Join-Path $extDir 'eps-1.0.0') -Recurse