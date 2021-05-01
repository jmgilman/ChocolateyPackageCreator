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
$hasDefender = $False

$isoConfig = Import-PowerShellDataFile (Join-Path $PackagePath 'iso.psd1')
$isoPackage = New-ChocolateyPackage $PackagePath $isoConfig

$packages = [System.Collections.ArrayList]@()
$packagesPath = Join-Path $PackagePath 'packages'
foreach ($packageFile in (Get-ChildItem $packagesPath -Filter '*.psd1' -Recurse)) {
    $packageConfig = Import-PowerShellDataFile $packageFile.FullName
    $packages.Add((New-ChocolateyPackage $packageFile.Parent.FullName $packageConfig))
}

$chocoIsoPackage = New-ChocolateyISOPackage $isoPackage $packages
$packageFiles = Build-ChocolateyISOPackage `
    -Package $chocoIsoPackage `
    -OutPath $OutPath `
    -ScanFiles:$hasDefender `
    -Verbose:$verbose


$packageFiles