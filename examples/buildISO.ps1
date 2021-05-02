[cmdletbinding()]
param(
    [string] $PackageFile,
    [string] $OutPath
)

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot '..\ChocolateyPackageCreator') -Force

if (!(Test-Path $PackageFile)) {
    throw 'Cannot find meta package file at {0}' -f $ConfigFile
}

if (!(Test-Path $OutPath)) {
    throw 'The output path must already exist at {0}' -f $OutPath
}

$verbose = $PSCmdlet.MyInvocation.BoundParameters['Verbose']
$hasDefender = Test-Path (Join-Path $env:ProgramFiles 'Windows Defender/MpCmdRun.exe' -ErrorAction SilentlyContinue)
$packagePath = Split-Path -Parent $PackageFile

# Load meta package
Write-Verbose ('Loading meta package at {0}' -f $PackageFile)
$metaConfig = Import-PowerShellDataFile $PackageFile
$metaPackage = New-ChocolateyPackage $packagePath $metaConfig

# Load ISO package
$isoPackagePath = Join-Path $packagePath 'iso.psd1'
if (!(Test-Path $isoPackagePath)) {
    throw 'Could not find ISO package at {0}' -f $isoPackagePath
}

Write-Verbose ('Loading iso package at {0}' -f $isoPackagePath)
$isoConfig = Import-PowerShellDataFile $isoPackagePath

# Load all sub packages
$packages = [System.Collections.ArrayList]@()
$packagesPath = Join-Path $packagePath 'packages'

Write-Verbose ('Searching for sub-packages at {0}...' -f $packagesPath)
$subPackagePaths = Get-ChildItem $packagesPath -Filter '*.psd1' -Recurse
foreach ($subPackageFile in $subPackagePaths) {
    Write-Verbose ('Loading sub-package at {0}...' -f $subPackageFile.FullName)
    $packageConfig = Import-PowerShellDataFile $subPackageFile.FullName
    $packages.Add((New-ChocolateyPackage $subPackageFile.Parent.FullName $packageConfig))
}

# Create ISO package
$isoPackage = New-ChocolateyISOPackage $PackagePath $isoConfig $metaPackage $packages

Write-Verbose 'Building packages...'
$packageFiles = Build-ChocolateyISOPackage `
    -Package $IsoPackage `
    -OutPath $OutPath `
    -ScanFiles:$hasDefender `
    -Verbose:$verbose

$packageFiles