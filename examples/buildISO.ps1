[cmdletbinding()]
param(
    [string] $PackagePath,
    [string] $OutPath
)

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot '..\ChocolateyPackageCreator') -Force

if (!(Test-Path $PackagePath)) {
    throw 'Cannot find package files at {0}' -f $ConfigFile
}

if (!(Test-Path $OutPath)) {
    throw 'The output path must already exist at {0}' -f $OutPath
}

$verbose = $PSCmdlet.MyInvocation.BoundParameters['Verbose']
$hasDefender = Test-Path (Join-Path $env:ProgramFiles 'Windows Defender/MpCmdRun.exe' -ErrorAction SilentlyContinue)

# Load all sub packages
$packages = [System.Collections.ArrayList]@()
$packagesPath = Join-Path $PackagePath 'packages'
Write-Verbose ('Searching for sub-packages at {0}...' -f $packagesPath)
foreach ($packageFile in (Get-ChildItem $packagesPath -Filter '*.psd1' -Recurse)) {
    Write-Verbose ('Loading sub-package at {0}...' -f $packageFile.FullName)
    $packageConfig = Import-PowerShellDataFile $packageFile.FullName
    $packages.Add((New-ChocolateyPackage $packageFile.Parent.FullName $packageConfig))
}

# Load ISO package
$isoPackagePath = Join-Path $PackagePath 'iso.psd1'
if (!(Test-Path $isoPackagePath)) {
    throw 'Could not find ISO package at {0}' -f $isoPackagePath
}

Write-Verbose ('Loading ISO package at {0}...' -f $isoPackagePath)
$isoConfig = Import-PowerShellDataFile (Join-Path $PackagePath 'iso.psd1')
$isoPackage = New-ChocolateyISOPackage $PackagePath $isoConfig $packages

Write-Verbose 'Building packages...'
$packageFiles = Build-ChocolateyISOPackage `
    -Package $IsoPackage `
    -OutPath $OutPath `
    -ScanFiles:$hasDefender `
    -Verbose:$verbose


$packageFiles