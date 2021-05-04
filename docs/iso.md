# Creating an ISO Package

In this example we will run through creating an ISO package for the popular
disaster recovery software, Veeam Backup & Replication. An ISO package is
nothing more than a combination of Chocolatey packages that, together, install
complex software often distributed in an ISO file. In the case of Veeam, the
installation process spans 11 MSI installers, not including dependencies. To
ease the package creation process, the ISO package format was created.

# Structure

The build process for ISO packages imposes a structure on how the directory
containing your package configurations is laid out. It looks like this:

```
/iso.psd1
/packagename.psd1
/packages
/packages/subpackage1.psd1
/packages/subpackage2.psd1
```

The first file, `iso.psd1`, is the ISO package file that is responsible for
downloading the ISO image to the local machine. Since ISO files tend to be very
large, and NuGet repositories tend to struggle with large files, the ISO package
format does not package the ISO file into itself. Instead, it creates an
installation script which downloads the ISO to the end-user's local hard drive.
This file is responsible for pointing to the source where the ISO can be
downloaded from. In on-premise environments with no internet connectivity, it's
recommended you host the ISO file on an internal machine and point the
installation file to that.

The second file, `packagename.psd1`, is the meta package that ties all the other
packages together. This package will not have any files associated with it and
will instead have all other packages as depdendencies. The end result is that
when a user runs `choco install packagename` the entirety of the software will
be installed on the users computer. Note that care should be taken in ordering
the dependencies correctly to ensure a successful installation of the software.

The remaining files exist under the `packages` subdirectory and are simply
normal package configuration files with one unique exception which will be
covered later. There should be one file per MSI/EXE installer in the ISO image.


## The ISO package

As noted above, the ISO package points to the source of the ISO file and is
responsible for downloading it to the end-user's hard drive. The configuration
for Veeam looks like this:

```powershell
@{
    name     = 'veeam-iso'
    isoFile  = @{
        url        = 'https://download2.veeam.com/VBR/v11/VeeamBackup&Replication_11.0.0.837_20210220.iso'
        sha1       = 'D6E9F7DB3BA1A4782028773562AA036365724AE4'
        importPath = 'veeam.iso'
    }
    manifest = @{
        metadata = @{
            id                       = 'veeam-iso'
            title                    = 'Veeam Backup & Replication ISO'
            version                  = '11.0.0.837'
            authors                  = 'Veeam'
            owners                   = 'Joshua Gilman'
            summary                  = 'Installs the contents of the Veeam Backup & Replication ISO'
            description              = 'Veeam Backup & Replication is a backup solution developed for VMware vSphere and Microsoft Hyper-V virtual environments. Veeam Backup & Replication provides a set of features for performing data protection and disaster recovery tasks.'
            projectUrl               = 'http://www.veeam.com/'
            packageSourceUrl         = 'https://github.com/jmgilman/ChocolateyPackageManager'
            tags                     = 'veeam backup replication iso'
            copyright                = '2021 Veeam'
            licenseUrl               = 'https://www.veeam.com/eula.html'
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

The format should look familiar, the only deviation from the normal package
configuration is the existence of the `isoFile` property and the lack of most
of the other properties. The `isoFile` property follows the same format as the
`remoteFiles` section of a normal configuration and should point to the location
where the required ISO file can be downloaded. Underneath the hood, this package
has a custom installation script which downloads and unpacks the ISO:

```powershell
Function Expand-DiskImage {
    param(
        [string] $Path,
        [string] $Destination
    )

    Write-Host ('Mounting image at {0}...' -f $Path)
    Mount-DiskImage -ImagePath $Path
    $img = Get-DiskImage -ImagePath $Path
    $driveLetter = $img | Get-Volume | Select-Object -ExpandProperty DriveLetter
    $drivePath = Get-PSDrive -Name $driveLetter | Select-Object -ExpandProperty Root

    Write-Host ('Copying ISO files from {0} to {1}' -f $drivePath, $Destination)
    Copy-Item (Join-Path $drivePath '*') $Destination -Recurse | Out-Null

    Write-Host 'Unmounting image...'
    Dismount-DiskImage -ImagePath $Path | Out-Null
}

Function Invoke-Unshim {
    param($BuildPath)

    $exeFiles = Get-ChildItem $BuildPath -Filter '*.exe' -Recurse
    foreach ($file in $exeFiles) {
        $ignoreFile = $file.FullName + '.ignore'

        Write-Host('Preventing shim of {0} with {1}...' -f $file.FullName, $ignoreFile)
        Set-Content $ignoreFile ''
    }
}

$packageName = 'veeam-iso'
$filePath = 'veeam.iso'
$url = 'https://download2.veeam.com/VBR/v11/VeeamBackup&Replication_11.0.0.837_20210220.iso'
$hash = 'D6E9F7DB3BA1A4782028773562AA036365724AE4'

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$packageDir = Split-Path -parent $scriptDir
$fileFullPath = Join-Path $packageDir $filePath

Write-Host 'Downloading ISO file...'
Get-ChocolateyWebFile `
    -PackageName $env:ChocolateyPackageName `
    -FileFullpath $fileFullPath `
    -Url $url `
    -Checksum $hash `
    -ChecksumType sha1

Write-Host 'Extracting ISO contents...'
Expand-DiskImage $fileFullPath $packageDir

Write-Host 'Removing ISO file...'
Remove-Item $fileFullPath -Force

Write-Host 'Preventing shimming of exe files...'
Invoke-Unshim $packageDir
```

This script does the following:

* Calls `Get-ChocolateyWebFile` to download the ISO file to the local system
* Calls `Expand-DiskImage` to mount the ISO image, copy the contents to the 
local package directory, and then unmounts the image
* Deletes the ISO image
* Prevents the shimming of any EXE's found in the image contents

The result is a local copy of the ISO contents at the following path:
`C:\ProgramData\chocolatey\lib\veeam-iso`. This is the most important detail to
understand about the ISO package format as the existence of the ISO on the local
system is what enables the sub-packages to work correctly. All sub-packages will
have a hard dependency on this ISO package to ensure that the contents have been
downloaded already. 

## The Meta Package

The meta package is in the normal package format and only contains dependencies
on the rest of the packages belonging to the ISO:

```powershell
@{
    name          = 'veeam'
    processScript = ''
    shim          = $False
    installer     = @{}
    localFiles    = @()
    remoteFiles   = @()
    manifest      = @{
        metadata = @{
            id                       = 'veeam'
            title                    = 'Veeam Backup & Replication'
            version                  = '11.0.0.837'
            authors                  = 'Veeam'
            owners                   = 'Joshua Gilman'
            summary                  = 'Installs Veeam Backup & Replication'
            description              = 'Veeam Backup & Replication is a backup solution developed for VMware vSphere and Microsoft Hyper-V virtual environments. Veeam Backup & Replication provides a set of features for performing data protection and disaster recovery tasks.'
            projectUrl               = 'http://www.veeam.com/'
            packageSourceUrl         = 'https://github.com/jmgilman/ChocolateyPackageManager'
            tags                     = 'veeam backup replication'
            copyright                = '2021 Veeam'
            licenseUrl               = 'https://www.veeam.com/eula.html'
            requireLicenseAcceptance = 'false'
            dependencies             = @(
                @{
                    id      = 'veeam-catalog'
                    version = '[11.0.0.837]'
                },
                @{
                    id      = 'veeam-server'
                    version = '[11.0.0.837]'
                },
                @{
                    id      = 'veeam-console'
                    version = '[11.0.0.837]'
                },
                @{
                    id      = 'veeam-explorer-ad'
                    version = '[11.0.0.837]'
                },
                @{
                    id      = 'veeam-explorer-exchange'
                    version = '[11.0.0.837]'
                },
                @{
                    id      = 'veeam-explorer-oracle'
                    version = '[11.0.0.837]'
                },
                @{
                    id      = 'veeam-explorer-sharepoint'
                    version = '[11.0.0.837]'
                },
                @{
                    id      = 'veeam-explorer-sql'
                    version = '[11.0.0.837]'
                },
                @{
                    id      = 'veeam-redistr-windows'
                    version = '[11.0.0.837]'
                },
                @{
                    id      = 'veeam-redistr-linux'
                    version = '[11.0.0.837]'
                },
                @{
                    id      = 'veeam-redistr-mac'
                    version = '[11.0.0.837]'
                }
            )
        }
        files    = @()
    }
}
```

As can be seen, the package lacks any local files, remote files, or installers.
Instead, it consists of a series of dependencies that, together, install a fully
working instance of the Veeam Backup & Replication server. The goal should be
to replicate what is produced when a user runs the normal GUI installer. In
other words, if there are optional packages not normally installed by the GUI
installer, they should be left out of this configuration. 

Note that the order is important as Chocolatey will instal the dependencies in
the order given above unless the dependency graph forces it out of order. Not
all dependencies are listed here - the `veeam-server` package has a number of
third-party dependencies that will be picked up when Chocolatey reads the
package metadata. The best way to think of this package is the "glue" of the
whole thing - it brings it all together and installs the full software stack on
the user's machine. 

## The Sub Packages

The remaining files should exist under the `packages` subdirectory and should
be individual package configuration files that each reference an MSI/EXE
installer in the ISO file. As mentioned above, these are normal package
configuration files, with one notable exception:

```powershell
@{
    name          = 'veeam-catalog'
    processScript = ''
    shim          = $False
    installer     = @{
        scriptPath      = 'tools'
        installerPath   = 'Catalog\VeeamBackupCatalog64.msi'
        installerPath64 = ''
        installerType   = 'msi'
        exitCodes       = @(0, 1638, 1641, 3010)
        flags           = '/qn /norestart'
        arguments       = @{
            ACCEPT_THIRDPARTY_LICENSES = '1'
            INSTALLDIR                 = ''
            VM_CATALOGPATH             = ''
            VBRC_SERVICE_USER          = ''
            VBRC_SERVICE_PASSWORD      = ''
            VBRC_SERVICE_PORT          = ''
        }
    }
    localFiles    = @()
    remoteFiles   = @()
    manifest      = @{
        metadata = @{
            id                       = 'veeam-catalog'
            title                    = 'Veeam Backup & Replication Catalog'
            version                  = '11.0.0.837'
            authors                  = 'Veeam'
            owners                   = 'Joshua Gilman'
            summary                  = 'Installs the Veeam Backup & Replication Catalog service'
            description              = 'Veeam Backup & Replication is a backup solution developed for VMware vSphere and Microsoft Hyper-V virtual environments. Veeam Backup & Replication provides a set of features for performing data protection and disaster recovery tasks.'
            projectUrl               = 'http://www.veeam.com/'
            packageSourceUrl         = 'https://github.com/jmgilman/ChocolateyPackageManager'
            tags                     = 'veeam backup replication catalog'
            copyright                = '2021 Veeam'
            licenseUrl               = 'https://www.veeam.com/eula.html'
            requireLicenseAcceptance = 'false'
            dependencies             = @(
                @{
                    id      = 'veeam-iso'
                    version = '[11.0.0.837]'
                },
                @{
                    id      = 'dotnet-472'
                    version = ''
                }
            )
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

Notice in the above configuration that the `installerPath` property is pointing
to a relative directory that will not exist in the package: 
`Catalog\VeeamBackupCatalog64.msi`. So how does this work? When the ISO package
is being built, the module will automatically append a relative path to the
`installerPath` that will force it to point to the directory where the ISO
file contents have already been downloaded. For example, here is what the
compiled `ChocolateyInstall.ps1` script looks like for the above configuration:

```powershell
$filePath = '..\veeam-iso\Catalog\VeeamBackupCatalog64.msi'
```

Later on in the code this is expanded to a fully qualified path:

```powershell
$fileLocation = (Get-Item $fileLocation).FullName # Resolve relative paths
```

Which would result in a final location of: 
`C:\ProgramData\chocolatey\lib\veeam-iso\Catalog\VeeamBackupCatalog64.msi`.

The point to understand, then, is that in the subpackages of an ISO package the
**installer path should be relative from the root of the ISO file**. If you were
to mount the contents of the Veeam ISO image, you would find something like the
following: `E:\Catalog\VeeamBackupCatalog64.msi`. The benefit of this approach
is you don't need to be concerend about where or how the files are getting to
the local system, only with creating the packages and referencing the installer
path as shown above. 

# Building the ISO Package

With the structure in place we can now build out the contents of the ISO
package. Note that we reference the singular form of the word package here, but
technically an ISO package is a conglomeration of multiple packages. The build
process will end up producing several `.nupkg` files which, together, make up
the ISO package. Recall that the meta package is what is tying all of these
packages together via dependencies - so in a production environment all of these
packages will need to be pushed to the local NuGet repository and the end-user
only needs to be aware of the existence of the metapackage 
(i.e. `choco install veeam`). 

Building out the package does take a bit more work than a normal package as
all the configurations must be loaded and passed to the function which creates
the `ChocolateyISOPackage` object. Here is an excerpt from the build script
which can be found in the examples directory:

```powershell
[cmdletbinding()]
param(
    [string] $PackageFile,
    [string] $OutPath
)

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot '..\ChocolateyPackageCreator') -Force

if (!(Test-Path $PackageFile)) {
    throw 'Cannot find meta package file at {0}' -f $ConfigFile
}

if (!(Test-Path $OutPath)) {
    throw 'The output path must already exist at {0}' -f $OutPath
}

$verbose = $PSCmdlet.MyInvocation.BoundParameters['Verbose']
$hasDefender = Test-Path (Join-Path $env:ProgramFiles 'Windows Defender/MpCmdRun.exe' -ErrorAction SilentlyContinue)
$packagePath = Split-Path -Parent $PackageFile

# Load meta package
Write-Verbose ('Loading meta package at {0}' -f $PackageFile)
$metaConfig = Import-PowerShellDataFile $PackageFile
$metaPackage = New-ChocolateyPackage $packagePath $metaConfig

# Load ISO package
$isoPackagePath = Join-Path $packagePath 'iso.psd1'
if (!(Test-Path $isoPackagePath)) {
    throw 'Could not find ISO package at {0}' -f $isoPackagePath
}

Write-Verbose ('Loading iso package at {0}' -f $isoPackagePath)
$isoConfig = Import-PowerShellDataFile $isoPackagePath

# Load all sub packages
$packages = [System.Collections.ArrayList]@()
$packagesPath = Join-Path $packagePath 'packages'

Write-Verbose ('Searching for sub-packages at {0}...' -f $packagesPath)
$subPackagePaths = Get-ChildItem $packagesPath -Filter '*.psd1' -Recurse
foreach ($subPackageFile in $subPackagePaths) {
    Write-Verbose ('Loading sub-package at {0}...' -f $subPackageFile.FullName)
    $packageConfig = Import-PowerShellDataFile $subPackageFile.FullName
    $packages.Add((New-ChocolateyPackage $subPackageFile.Parent.FullName $packageConfig))
}

# Create ISO package
$isoPackage = New-ChocolateyISOPackage $PackagePath $isoConfig $metaPackage $packages
```

The general flow is as follows:

* Load the contents of the meta package configuration
* Load the contents of the ISO package configuration
* Iterate through all sub-packages present in the `packages` subdirectory and
load their package configurations.
* Pass all these packages to the `New-ChocolateyISOPackage` function to get a
`ChocolateyISOPackage` object back

The resulting object can then be passed to the build function:

```powershell
$packageFiles = Build-ChocolateyISOPackage `
    -Package $IsoPackage `
    -OutPath $OutPath `
    -ScanFiles:$hasDefender `
    -Verbose:$verbose
```

This looks indetical to the `Build-ChocolateyPackage` function except that it
takes a `ChocolateyISOPackage` object and, of course, builds out many more
packages. The `$OutPath` directory, after the build finishes, will contain
multiple `.nugpk` files that, together, make up the ISO package. 

# Publishing the ISO Image

Publishing the ISO package is as simply as calling `Publish-ChocolateyPackage`
on each of the packages generated by the build. The build function will return
an array of fully qualified paths to each of the packages generated in order to
ease this process:

```powershell
foreach ($packageFile in $packageFiles) {
    Publish-ChocolateyPackage `
        -Repository $Repository `
        -ApiKey $env:API_KEY `
        -PackageFile $PackageFile
}
```