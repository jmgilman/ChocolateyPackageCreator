param($BuildPath, $Package)

$toolsDir = Join-Path $BuildPath 'tools'
$installer = Join-Path $BuildPath $Package.RemoteFiles[0].ImportPath
$installerName = Split-Path $installer -Leaf

# Extract installer contents
Start-Process $installer -ArgumentList ('/q') -WorkingDirectory $toolsDir -NoNewWindow -Wait

$sqlFolder = Join-Path $toolsDir ($installerName -replace '.exe', '')
Move-Item (Join-Path $sqlFolder '*') $toolsDir

Remove-Item $sqlFolder -Recurse
Remove-Item $installer