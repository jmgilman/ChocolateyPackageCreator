[cmdletbinding()]
param(
    [string] $ConfigFile,
    [string] $OutPath
)

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot '..\ChocolateyPackageCreator') -Force

if (!(Test-Path $ConfigFile)) {
    throw 'Cannot find config file at {0}' -f $ConfigFile
}

if (!(Test-Path $OutPath)) {
    throw 'The output path must already exist at {0}' -f $OutPath
}

$verbose = $PSCmdlet.MyInvocation.BoundParameters['Verbose']
$hasDefender = Test-Path (Join-Path $env:ProgramFiles 'Windows Defender/MpCmdRun.exe' -ErrorAction SilentlyContinue)


$config = Import-PowerShellDataFile $ConfigFile
$packagePath = New-ChocolateyPackage (Split-Path $ConfigFile) $config | 
    Build-ChocolateyPackage -OutPath $OutPath -ScanFiles:$hasDefender -Verbose:$verbose

$packagePath