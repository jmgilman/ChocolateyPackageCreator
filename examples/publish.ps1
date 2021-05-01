[cmdletbinding()]
param(
    [string] $Repository,
    [string] $PackageFile,
    [ValidateSet('Chocolatey', 'NuGet')]
    [string] $Tool = 'Chocolatey',
    [switch] $Force
)

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot '..\ChocolateyPackageCreator') -Force

if (!$env:API_KEY) {
    throw 'Please supply the NuGet API key via the `API_KEY` environment variable'
}

$verbose = $PSCmdlet.MyInvocation.BoundParameters['Verbose']
Publish-ChocolateyPackage `
    -Repository $Repository `
    -ApiKey $env:API_KEY `
    -PackageFile $PackageFile `
    -Tool $Tool `
    -Force:$Force `
    -Verbose:$verbose