# Chocolatey Package Creator
> Powershell module for creating internal Chocolatey packages

## Installation
```
$> Install-Module ChocolateyPackageCreator
```

## Usage
```
$> New-ChocolateyPackageConfig C:\my\package
# Modify package files
$> $configFile = 'C:\my\package\package.psd1'
$> $outPath = 'C:\my\package\bin'
$> $config = Import-PowerShellDataFile $configFile
$> $packagePath = New-ChocolateyPackage (Split-Path $configFile) $config | 
    Build-ChocolateyPackage -OutPath $outPath
$> Publish-ChocolateyPackage `
    -Repository 'http://my.nuget.com/repository' `
    -ApiKey $env:API_KEY `
    -PackageFile $packagePath
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