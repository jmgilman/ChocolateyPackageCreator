[cmdletbinding()]
param(
    [string] $Repository,
    [string] $PackageFile,
    [switch] $Force
)

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot '..\ChocolateyPackageCreator') -Force

if (!$env:API_KEY) {
    throw 'Please supply the NuGet API key via the `API_KEY` environment variable'
}

Publish-ChocolateyPackage -Repository $Repository -ApiKey $env:API_KEY -PackageFile $PackageFile -Force:$Force