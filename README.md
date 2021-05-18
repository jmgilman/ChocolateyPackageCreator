# Chocolatey Package Creator
> Powershell module for creating internal Chocolatey packages

## Installation
```
$> Install-Module ChocolateyPackageCreator
```

## Usage

For a more in-depth guide, see [Getting Started](https://github.com/jmgilman/ChocolateyPackageCreator/blob/master/docs/getting_started.md). Create a new package template:
```powershell
$> New-ChocolateyPackageConfig C:\my\package
```

Modify the contents of the template package to fit the needs of the package
you are trying to create. For more in-depth documentation and examples, see the
`examples` directory. To understand the schema of a package file, see the
[schema documentation](docs/schema.md). When ready, build the package:

```powershell
$> $config = Import-PowerShellDataFile 'C:\my\package\package.psd1'
$> $packagePath = New-ChocolateyPackage (Split-Path $configFile) $config | 
    Build-ChocolateyPackage -OutPath 'C:\my\package\bin'
```

And then publish it:

```powershell
$> Publish-ChocolateyPackage `
    -Repository 'http://my.nuget.com/repository' `
    -ApiKey $env:API_KEY `
    -PackageFile $packagePath
```

## Features

* Define all package elements in a single configuration file
* Automatically download and scan external files
* Easily extendable with custom logic in the package creation process
* Create and deploy packages with a single module

## Meta
Joshua Gilman - joshuagilman@gmail.com

Distributed under the MIT license. See LICENSE for more information.

https://github.com/jmgilman