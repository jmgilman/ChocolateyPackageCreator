# Introduction

The ChocolateyPackageCreator Powershell module is a tool which can be used to
simplify the process of creating internal Chocolatey packages, especially when
easy automation is desired. It has been built to provide support for the most
basic package types, like shimming a single executable, to complex package types,
like installing multiple packages off a single ISO image. The purpose of this
guide is to provide enough of an introduction to the methodology underlying
the module to get you up to speed on creating your first few packages.

# The Basics

The easiest way to come up to speed on using this module is by example. We will
start with a very basic example which packages the 7zip CLI tool and then move
onto a more complex example.

## Package Configuration File

```powershell
@{
    name          = '7zip'
    processScript = ''
    shim          = $True
    installer     = @{}
    localFiles    = @()
    remoteFiles   = @(
        @{
            url        = 'https://www.7-zip.org/a/7z1900-x64.exe'
            sha1       = '9FA11A63B43F83980E0B48DC9BA2CB59D545A4E8'
            importPath = 'tools/7z.exe'
        }
    )
    manifest      = @{
        metadata = @{
            id                       = '7zip'
            title                    = '7Zip File Archiver'
            version                  = '19.00'
            authors                  = 'Igor Pavlov'
            owners                   = 'Joshua Gilman'
            summary                  = 'Installs 7Zip CLI tool'
            description              = '7-Zip is a file archiver with a high compression ratio.'
            projectUrl               = 'https://www.7-zip.org/'
            packageSourceUrl         = 'https://github.com/jmgilman/ChocolateyPackageManager'
            tags                     = '7zip file archive'
            copyright                = '2021 Igor Pavlov'
            licenseUrl               = 'http://www.7-zip.org/license.txt'
            requireLicenseAcceptance = 'false'
            dependencies             = @()
        }
        files    = @(
            @{
                src    = 'tools\**'
                target = 'tools'
            }
        )
    }
}
```

This can be intimidating at first, but most of it becomes easy to digest once
the general architecture is understood:

* **Name:** A unique name used to identify the package in logs
* **processScript:** A optional path to a Powershell file that will be executed
prior to the package being built. We will cover this more in-depth in another
example.
* **Shim:** Whether or not executables in this package should be [shimmed](https://docs.chocolatey.org/en-us/features/shim). In other words, whether any found executables should be made
available in the system PATH. Setting this to false will automatically generate
.ignore files to prevent Chocolatey from shimming which is its default behavior.
* **Installer:** Whether or not to generate a `ChocolateyInstall.ps1` file for
installing this package. This is optional and is provided for convenience and
we will cover it more in-depth in another example.
* **LocalFiles:** Which local files, if any, to copy to the package before
building. The `localPath` to the files are relative to the `PackagePath` parameter
which is defined when creating a new package with `New-ChocolateyPackage`. The
`importPath` is relative to the root of the package directory. 
* **RemoteFiles:** Similar to the local files except the source is a remote URL
from which to download the file. Additionally, an optional hash can be provided
in order to validate the downloaded file before building. 
* **Manifest:** This property is simply a wrapper around the [Chocolatey NuSpec](https://docs.chocolatey.org/en-us/create/create-packages#nuspec)
file which is required in all packages. When a package is created the NuSpec
file is automatically generated from this property and imported into the package.

## Building a Package

Now that we understand the basics of package file format, how would we actually
use the above example? First, we would create the `ChocolateyPackage` object:

```powershell
$packageConfigPath = 'C:\packages\7zip\package.psd1'
$packageConfig = Import-PowerShellDataFile $packageConfigPath
$package = New-ChocolateyPackage (Split-Path -Parent $packageConfigPath) $package
```

In the above example we assume the path to the package file we created earlier
is `C:\packages\7zip\package.psd1` and so we pass that file to 
`Import-PowerShellDataFile` which returns an object containing the configuration
data within the file. We then call `New-ChocolateyPackage` with two parameters,
the path to the package root and the contents of the package configuration file.
Recall that the module uses the package path to find the subsidiary files
associated with a package - like `LocalFiles` or a `ProcessScript`. This
function will take the raw configuration data and turn it into a
`ChocolateyPackage` object which we can further use in other functions.

The next step is to actually build the package and produce a package file:

```powershell
$packagePath = Build-ChocolateyPackage -Package $package -OutPath 'C:\packages\bin'
```

The above function has many more parameters that can be utilized, but only the
two used here are required. The `Package` parameter is the `ChocolateyPackage`
object we created earlier and the `OutPath` parameter is the location where we
would like the package file created at. The function returns the fully qualified
path to the package, which in this case would be `C:\packages\bin\7zip.19.00.nupkg`.

## Publishing a Package 

With the package created, all that's left is to upload it to our local NuGet
repository for consumption by Chocolatey:

```powershell
Publish-ChocolateyPackage `
    -Repository 'http://my.nuget.com/nuget' `
    -ApiKey 'myapikey' `
    -PackageFile $packagePath
```

Again, there are a few additional parameters available, but only the three used
here are required. The `Repository` is the URL path to the desired NuGet
repository, the `ApiKey` is an API key with sufficient privileges to publish
the package, and the `PackageFile` is the path to the package file to publish.

## Understanding the Output

Let's expand the contents of the `7zip.19.00.nupkg` file generated above:

```
/_rels/.rels
/package/services/metadata/core-properties/<ID>.psmdcp
/tools/7z.exe
/[Content Types].xml
/7zip.nuspec
```

Most of these files are automatically generated by Chocolatey and are required
for NuGet packages, but two of them were created by the build process: the
`7z.exe` file was automatically downloded from the URL provided in our
`RemoteFiles` property and imported into the `tools` directory as specified by
the `ImportPath`. Since `Shim` was set to true, Chocolatey will automatically 
make this file available via with system PATH environment variable. The 
`7zip.nuspec` file was automatically generated using the manifest data provided 
in the package configuration. You can open it up and see that it matches:

```xml
<?xml version="1.0"?>
<package xmlns="http://schemas.microsoft.com/packaging/2011/08/nuspec.xsd">
  <metadata>
    <id>7zip</id>
    <version>19.00</version>
    <title>7Zip File Archiver</title>
    <authors>Igor Pavlov</authors>
    <owners>Joshua Gilman</owners>
    <licenseUrl>http://www.7-zip.org/license.txt</licenseUrl>
    <projectUrl>https://www.7-zip.org/</projectUrl>
    <requireLicenseAcceptance>false</requireLicenseAcceptance>
    <description>7-Zip is a file archiver with a high compression ratio.</description>
    <summary>Installs 7Zip CLI tool</summary>
    <copyright>2021 Igor Pavlov</copyright>
    <tags>7zip file archive</tags>
    <packageSourceUrl>https://github.com/jmgilman/ChocolateyPackageManager</packageSourceUrl>
  </metadata>
</package>
```

# Advanced Example

Let's make another package but this time use a few additional features of the
module. This time we'll create a package that installs Chrome Enterprise. Here
is the package configuration:

```powershell
@{
    name          = 'chrome-enterprise'
    processScript = 'process.ps1'
    shim          = $True
    installer     = @{
        scriptPath      = 'tools'
        installerPath   = 'tools/GoogleChromeStandaloneEnterprise64.msi'
        installerPath64 = ''
        installerType   = 'msi'
        exitCodes       = @(0)
        flags           = '/qn'
        arguments       = @{}
    }
    localFiles    = @()
    remoteFiles   = @(
        @{
            url        = 'https://dl.google.com/tag/s/appguid%3D%7B8A69D345-D564-463C-AFF1-A69D9E530F96%7D%26iid%3D%7B28B3FC2A-8F28-9145-D051-455305F69948%7D%26lang%3Den%26browser%3D4%26usagestats%3D0%26appname%3DGoogle%2520Chrome%26needsadmin%3Dtrue%26ap%3Dx64-stable-statsdef_0%26brand%3DGCEB/dl/chrome/install/GoogleChromeEnterpriseBundle64.zip'
            sha1       = '191A76F3084CD293FB8B56AEF9952236930BFE7D'
            importPath = 'tools/chrome.zip'
        }
    )
    manifest      = @{
        metadata = @{
            id                       = 'chrome-enterprise'
            title                    = 'Google Chrome'
            version                  = '90.0.4430.85'
            authors                  = 'Google'
            owners                   = 'Joshua Gilman'
            summary                  = 'Installs Google Chrome'
            description              = "Get more done with the new Google Chrome. A more simple, secure, and faster web browser than ever, with Google's smarts built-in."
            projectUrl               = 'https://www.google.com/chrome/'
            packageSourceUrl         = 'https://github.com/jmgilman/ChocolateyPackageManager'
            tags                     = 'Google Chrome Browser Web'
            copyright                = '2021 Google'
            licenseUrl               = 'https://chromeenterprise.google/terms/chrome-service-license-agreement/'
            requireLicenseAcceptance = 'false'
            dependencies             = @()
        }
        files    = @(
            @{
                src    = 'tools\**'
                target = 'tools'
            }
        )
    }
}
```

Most of this should be easy to understand at this point - we've only added two
new things: an installation script and a process script.

## The Installation Script

By defining the `Installer` property, the module will automatically generate a
`ChocolateyInstall.ps1` file at build time. It has the following attributes:

* **ScriptPath:** The path, relative from the package root, where the
installation script will be created. It's best practice to include the script
in the same directory as the rest of your files, however, Chocolatey looks for
the script anywhere in the package and so it's technically not required to be in
one place.
* **InstallerPath:** The path, relative from the package root, where the package
installer file is located. This is the file that is passed to Chocolatey and is
usually an MSI or EXE file that installs the program. 
* **InstallerPath64:** An optional 64-bit version of the package installer file.
This is typically only used when a program offers both a 32-bit and 64-bit
version. By specifying the 32-bit installer in `InstallerPath` and the 64-bit
installer in `InstallerPath64`, Chocolatey will automatically install the
correct one based on the host's architecture at install time.
* **InstallerType:** The type of installer. Usually either `msi` or `exe`.
* **ExitCodes:** An array of valid exit codes that the installer can exit with.
Any exit code not in this array is considered a failure. 
* **Flags:** A list of flags to pass to the installer. This is usually used to
pass the parameters that perform a silent installation of the program.
* **Arguments:** A dictionary of valid arguments that the installer can take.
Most installers have a range of arguments that instruct it on how to install to
the local system and the installation script will automatically convert these
into the final string of arguments sent to the installer. It's important that
**all** valid arguments be specified here as the installation script also allows
the end-user to specify values for these arguments via parameters passed to
Chocolatey during the install.

The above configuration file produces the following `ChocolateyInstall.ps`
script:

```
$packageName = 'chrome-enterprise'
$filePath = 'GoogleChromeStandaloneEnterprise64.msi'
$filePath64 = ''
$fileType = 'msi'
$flags = '/qn'
$exitCodes = @(0)
$logLocation = '{0}\{1}.{2}.log' -f $env:TEMP,$env:ChocolateyPackageName,$env:ChocolateyPackageVersion

$arguments = @{}

$params = Get-PackageParameters

# Build arguments
if (($params.Count -gt 0) -and ($arguments.Count -eq 0)) {
    Write-Warning 'Parameters were given but this package does not take any parameters'
} elseif (($params.Count -gt 0) -and ($arguments.Count -gt 0)) {
    foreach($param in $params.GetEnumerator()) {
        if (!($param.Name -in $arguments.Keys)) {
            Write-Warning ('This package does not have a {0} parameter' -f $param.Name)
            continue
        }

        $arguments[$param.Name] = $param.Value
    }
}

# Build argument string
$silentArgs = $flags
$silentArgs += ' /l*v "{0}"' -f $logLocation
foreach($argument in $arguments.GetEnumerator()) {
    if ($argument.Value) {
        if ($fileType -eq 'exe') {
            $argString = ' /{0}="{1}"' -f $argument.Name, $argument.Value
        } else {
            $argString = ' {0}="{1}"' -f $argument.Name, $argument.Value
        }
        $silentArgs += $argString
    }
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$packageDir = Split-Path -Parent $scriptDir

$fileLocation = Join-Path $packageDir $filePath
$fileLocation = (Get-Item $fileLocation).FullName # Resolve relative paths

if ($filePath64) {
    $fileLocation64 = Join-Path $packageDir $filePath64
    $fileLocation64 = (Get-Item $fileLocation64).FullName
}

Write-Host ('Log location is {0}' -f $logLocation)
if ($filePath64) {
    Install-ChocolateyInstallPackage `
        -PackageName $packageName `
        -FileType $fileType `
        -File $fileLocation `
        -File64 $fileLocation64 `
        -SilentArgs $silentArgs.Trim() `
        -ValidExitCodes $exitCodes
} else {
    Install-ChocolateyInstallPackage `
        -PackageName $packageName `
        -FileType $fileType `
        -File $fileLocation `
        -SilentArgs $silentArgs.Trim() `
        -ValidExitCodes $exitCodes
}
```

As you can see, the installation script does a number of things by default. Of
note is that, as already mentioned, it builds the final argument string passed
to the installer by combining the arguments specified in the package
configuration and any parameters supplied by the end-user. Other than that, the
rest is a pretty typicaly install script, for more information on this file, see
the [Chocolatey documentation](https://docs.chocolatey.org/en-us/chocolatey-install-ps1).

## The Process Script

A process script can be supplied which will be run during the build after all
files have been copied to the package directory but before the package is
actually built. This is useful for performing additional operations on package
files, like extracting the contents of a zip archive in our case:

```powershell
param($BuildPath, $Package)

$toolsDir = Join-Path $BuildPath 'tools'
$chromeDir = Join-Path $toolsDir 'chrome'
$zipFile = Join-Path $BuildPath $Package.RemoteFiles[0].ImportPath 

New-Item -ItemType Directory $chromeDir
Expand-Archive $zipFile $chromeDir

Copy-Item (Join-Path $chromeDir 'installers/GoogleChromeStandaloneEnterprise64.msi') $toolsDir
Remove-Item $chromeDir -Recurse -Force
Remove-Item $zipFile
```

A process script takes two parameters:

* **BuildPath:** The full path to the root of the package folder
* **Package:** A copy of the `ChocolateyPackage` object for the current package

In the above example, we extract the zip archive previously downloaded by the
module for us and then copy the Chrome installer to the `tools` directory. Note
that the name of this file is the same one we specified in the `Installer`
property as this is the file that the installation script will call to actually
perform the install of Chrome. After grabbing the installer we delete the rest
of the contents of the zip archive (including the archive itself) to minimize
the size of our package. 

# Conclusion

The above two examples cover a majority of the features offered by this module.
Additional parameters offered by the various functions can be found using the
normal Powershell documentation methods (i.e. `Get-Help`). To easily get started
with creating your first package, use the built-in generator:

```powershell
New-ChocolateyPackageConfig 'C:\packages\mypackage'
```