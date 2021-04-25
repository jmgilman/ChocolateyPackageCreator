# Summary
This directory contains examples of how to use the Chocolatey Package Creator 
module to dynamically create Chocolatey packages. 

* `chrome-enterprise`: Packages 64-bit Google Chrome browser
* `eps`: Packages the Powershell EPS module as a Chocolatey extension. This is 
used as a dependency in the `sql-express-adv` package.
* `sql-express-adv`: Packages Microsoft SQL Server 2019 (advanced)

# Architecture

## Package File
A PSD1 configuration file which contains all of the static details that define 
how a package is created. This file is strict and the module will complain if 
properties are added or omitted. At a high level a package file has the
following components:

* **Name**: A unique name to identify the package. This is usually identical to
the `id` property in the metadata.
* **ProcessScript**: Relative path to a script which will be called before the
package is built. See below for more details.
* **Shim**: Whether to allow Chocolatey to shim exe files found within the 
package. If set to false, the module will automatically generate `.ignore` 
files for every exe file in the package before building. 
* **LocalFiles**: An array of dictionaries with each dictionary representing a 
local file which should be copied to the package. The `LocalPath` is the
relative path to the file and the `ImportPath` is the relative path where the
file will be copied to in the package. 
* **RemoteFiles**: An array of dictionaries with each dictionary representing a 
remote file which should be downloaded to the package. Each remote file has an
associated `Url` where it can be downloaded from and an `ImportPath` which is
the relative path it will be saved to in the package. An optional hash can be
provided which will be used to validate the remote file has not changed.
* **Manifest**: This is basically the Chocolatey NuSpec file in a configuration
format. All properties here will match their respective property in the NuSpec
file.

## Process File
The `ProcessScript` property should point to a local Powershell script which
will be called after local and remote files are downloaded and before the
package is built. This property is optional and should be left blank if there is
no need for this functionality. 

The process script file will be passed two arguments: 

* `BuildPath`: The full path to the current build directory where package files
have been collected.
* `Package`: A copy of the ChocolateyPackage object being used for this build

The general purpose of the process script is to perform any additional actions 
on package files before the final package is compiled. Examples include 
unzipping files, removing unecessary files, or dynamically adding content like
configuration files.

The process script should not return anything and all output from it is
ignored by the module. Any conditions which arise that would prevent a
successful build should raise an exception to interrupt the build.

# Example Build
```
$> $packageFile = .\build.ps1 `
    -ConfigFile .\chrome-enterprise\package.psd1 `
    -OutPath (Get-Location) `
    -Verbose
$> $repo = 'http://my.nuget.com/repo'
$> $env:API_KEY = 'myapikey'
$> .\publish.ps1 `
    -Repository $rep `
    -PackageFile $packageFile `
    -Verbose
$> Remove-Item $packageFile
```