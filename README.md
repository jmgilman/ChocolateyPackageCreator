# Chocolatey Package Creator
> Powershell module for creating internal Chocolatey packages

## Installation
```
$> Install-Module ChocolateyPackageCreator
```

## Usage
```
$> $config = Import-PowerShellDataFile $ConfigFile
$> $packagePath = New-ChocolateyPackage (Split-Path $ConfigFile) $config | 
    Build-ChocolateyPackage -OutPath $OutPath
$> Publish-ChocolateyPackage `
    -Repository $Repository `
    -ApiKey $env:API_KEY `
    -PackageFile $PackageFile
```

For more in-depth directions see the examples folder.

## Features

* Define all package elements in a single configuration file
* Automatically download and scan external files
* Easily extendable with custom logic in the package creation process
* Create and deploy packages with a single module

## Meta
Joshua Gilman - joshuagilman@gmail.com

Distributed under the MIT license. See LICENSE for more information.

https://github.com/jmgilman