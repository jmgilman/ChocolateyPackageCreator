[cmdletbinding()]
param(
    [string] $Repository,
    [string] $PackagePath,
    [ValidateSet('Chocolatey', 'NuGet')]
    [string] $Tool = 'Chocolatey',
    [switch] $Force,
    [switch] $Recurse
)

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot '..\ChocolateyPackageCreator') -Force

if (!$env:API_KEY) {
    throw 'Please supply the NuGet API key via the `API_KEY` environment variable'
}

if ($Recurse) {
    $packageFiles = Get-ChildItem $PackagePath -Filter '*.nupkg' -Recurse
    if ($packageFiles.Count -eq 0) {
        throw 'Could not locate any packages at {0}' -f $PackagePath
    }
}
else {
    $packageFiles = @($PackagePath)
}

$verbose = $PSCmdlet.MyInvocation.BoundParameters['Verbose']
foreach ($packageFile in $packageFiles) {
    Write-Verbose ('Publishing package at {0}...' -f $packageFile)
    Publish-ChocolateyPackage `
        -Repository $Repository `
        -ApiKey $env:API_KEY `
        -PackageFile $PackageFile `
        -Tool $Tool `
        -Force:$Force `
        -Verbose:$verbose
}