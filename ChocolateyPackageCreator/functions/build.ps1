<#
.SYNOPSIS
    Compiles and builds the chocolatey package defined in the ChocolateyPackage
.DESCRIPTION
    Using the given ChocolateyPackage object, performs the following:
        * Creates a NuSpec file using the package manifest section
        * Downloads all remote files defined in the package
        * Copies all local files defined in the package
        * Runs an optional process script for post-processing of package files
        * Builds the package using choco pack
    The path to the final package file is returned. Note that during the build
    process a temporary directory is created in the OutPath directory to hold
    files and appropriate write permissions are required.
.PARAMETER Package
    The ChocolateyPackage to build
.PARAMETER OutPath
    The output directory where the final package file will be placed
.PARAMETER PreProcess
    An optional script block that is ran before the package process script. This
    script block receives the same parameters as the package process script.
.PARAMETER ChocolateyPath
    The path to the choco binary - defaults to 'choco'
.PARAMETER KeepFiles
    If set, does not delete the package files gathered during the build process.
    This is usually useful for debugging packages.
.PARAMETER ScanFiles
    Whether or not to scan any downloaded files using Windows Defender
.EXAMPLE
    Build-ChocolateyPackae `
        -Package $myPackage `
        -OutPath C:\path\to\package\output `
        -ScanFiles
.OUTPUTS
    The path to the final package file
#>
Function Build-ChocolateyPackage {
    [cmdletbinding()]
    param(
        [Parameter(
            Mandatory = $true,
            Position = 1,
            ValueFromPipeline = $true
        )]
        [ChocolateyPackage] $Package,
        [Parameter(
            Mandatory = $true,
            Position = 2
        )]
        [string] $OutPath,
        [scriptblock] $PreProcess = {},
        [string] $ChocolateyPath = 'choco',
        [switch] $ScanFiles,
        [switch] $KeepFiles
    )

    $buildDir = Join-Path $OutPath ($Package.Name + '-build')

    Write-Verbose ('Creating build directory at {0}...' -f $buildDir)
    New-Item -ItemType Directory $buildDir | Out-Null

    $nuspecPath = (Join-Path $buildDir ($Package.Manifest.Metadata.Id + '.nuspec'))

    Write-Verbose ('Creating NuSpec file at {0}...' -f $nuspecPath)
    $xml = New-ChocolateyNuSpec $Package.Manifest
    $xml.Save($nuspecPath)

    if ($Package.RemoteFiles) {
        Write-Verbose 'Downloading remote files...'
        foreach ($remoteFile in $Package.RemoteFiles) {
            $remoteFile | Get-RemoteFile -OutPath $buildDir -Scan:$ScanFiles | Out-Null
        }
    }

    if ($Package.LocalFiles) {
        Write-Verbose 'Copying local files...'
        foreach ($localFile in $Package.LocalFiles) {
            $outFile = Join-Path $buildDir $localFile.ImportPath
            if (!(Test-Path (Split-Path $outFile))) {
                New-Item -ItemType Directory -Path (Split-Path $outFile) | Out-Null
            }

            Write-Verbose ('Copying {0} to {1}...' -f $localFile.LocalPath, $outFile)
            Copy-Item $localFile.LocalPath $outFile | Out-Null
        }
    }

    if ($Package.Installer) {
        $installerFolder = Join-Path $buildDir $Package.Installer.ScriptPath
        if (!(Test-Path $installerFolder)) {
            New-Item -ItemType Directory $installerFolder | Out-Null
        }

        $installerFilePath = Join-Path $installerFolder 'ChocolateyInstall.ps1'
        $installerFileContents = Build-InstallerFile $Package

        Write-Verbose ('Writing installer file to {0}...' -f $installerFilePath)
        Set-Content $installerFilePath $installerFileContents | Out-Null
    }

    $PreProcess.Invoke($buildDir, $Package)

    if ($Package.processScript) {
        Write-Verbose ('Calling process script at {0}...' -f $Package.processScript) 
        $proc = Get-Command $Package.processScript | Select-Object -ExpandProperty ScriptBlock
        $proc.Invoke($buildDir, $Package) | Out-Null
    }

    if (!$Package.Shim) {
        Write-Verbose "Preventing shimming of exe's..."
        Invoke-Unshim $buildDir | Out-Null
    }

    $exitCode = Invoke-ChocolateyBuild `
        -NuspecFile $nuspecPath `
        -BuildPath $buildDir `
        -OutPath $OutPath `
        -ChocolateyPath $ChocolateyPath

    if ($exitCode -ne 0) {
        throw 'The Chocolatey package process exited with non-zero exit code: {0}' -f $proc.ExitCode
    }

    if (!$KeepFiles) {
        Write-Verbose 'Cleaning up...'
        Remove-Item $buildDir -Recurse -Force | Out-Null
    }
    
    $packageName = '{0}.{1}.nupkg' -f $Package.Manifest.Metadata.Id, $Package.Manifest.Metadata.Version
    Join-Path $OutPath $packageName
}

<#
.SYNOPSIS
    Compiles and builds the chocolatey ISO package defined in the ChocolateyISOPackage
.DESCRIPTION
    Using the given ChocolateyISOPackage object, performs the following:
        * Builds the ISO package using the static installer file
        * Iterates through and builds all subpackages, modifying their installer
          path to point to the ISO package folder
    The path to all built packages are returned. Note that during the build
    process a temporary directory is created in the OutPath directory to hold
    files and appropriate write permissions are required.
.PARAMETER Package
    The ChocolateyISOPackage to build
.PARAMETER OutPath
    The output directory where the final package files will be placed
.PARAMETER ChocolateyPath
    The path to the choco binary - defaults to 'choco'
.PARAMETER KeepFiles
    If set, does not delete the package files gathered during the build process.
    This is usually useful for debugging packages.
.PARAMETER ScanFiles
    Whether or not to scan any downloaded files using Windows Defender
.EXAMPLE
    Build-ChocolateyISOPackae `
        -Package $myPackage `
        -OutPath C:\path\to\package\output
.OUTPUTS
    An array of fully qualified paths pointing to all built package files
#>
Function Build-ChocolateyISOPackage {
    param(
        [Parameter(
            Mandatory = $true,
            Position = 1,
            ValueFromPipeline = $true
        )]
        [ChocolateyISOPackage] $Package,
        [Parameter(
            Mandatory = $true,
            Position = 2
        )]
        [string] $OutPath,
        [string] $ChocolateyPath = 'choco',
        [switch] $ScanFiles,
        [switch] $KeepFiles
    )

    Write-Verbose 'Building ISO package...'
    $packageFiles = [System.Collections.ArrayList]@()
    $buildDir = Join-Path $OutPath ($Package.Name + '-build')

    Write-Verbose ('Creating build directory at {0}...' -f $buildDir)
    New-Item -ItemType Directory $buildDir | Out-Null

    $nuspecPath = (Join-Path $buildDir ($Package.Manifest.Metadata.Id + '.nuspec'))

    Write-Verbose ('Creating NuSpec file at {0}...' -f $nuspecPath)
    $xml = New-ChocolateyNuSpec $Package.Manifest
    $xml.Save($nuspecPath)

    $installerFolder = Join-Path $buildDir 'tools'
    if (!(Test-Path $installerFolder)) {
        New-Item -ItemType Directory $installerFolder | Out-Null
    }

    $installerFilePath = Join-Path $installerFolder 'ChocolateyInstall.ps1'
    $installerFileContents = Build-ISOInstallerFile $Package

    Write-Verbose ('Writing installer file to {0}...' -f $installerFilePath)
    Set-Content $installerFilePath $installerFileContents | Out-Null

    $exitCode = Invoke-ChocolateyBuild `
        -NuspecFile $nuspecPath `
        -BuildPath $buildDir `
        -OutPath $OutPath `
        -ChocolateyPath $ChocolateyPath

    if ($exitCode -ne 0) {
        throw 'The Chocolatey package process exited with non-zero exit code: {0}' -f $proc.ExitCode
    }

    if (!$KeepFiles) {
        Write-Verbose 'Cleaning up...'
        Remove-Item $buildDir -Recurse -Force | Out-Null
    }
    
    $packageName = '{0}.{1}.nupkg' -f $Package.Manifest.Metadata.Id, $Package.Manifest.Metadata.Version
    $packageFiles.Add((Join-Path $OutPath $packageName)) | Out-Null

    Write-Verbose 'Building sub packages...'
    foreach ($subPackage in $Package.Packages) {
        Write-Verbose ('Building {0}...' -f $subPackage.Name)
        $subPackage.Installer.InstallerPath = '..\{0}\{1}' -f $Package.Manifest.Metadata.Id, $subPackage.Installer.InstallerPath
        $packageFile = Build-ChocolateyPackage `
            -Package $subPackage `
            -OutPath $OutPath `
            -ChocolateyPath $ChocolateyPath `
            -ScanFiles:$ScanFiles `
            -KeepFiles:$KeepFiles
        $packageFiles.Add($packageFile) | Out-Null
    }

    Write-Verbose 'Building meta package...'
    Write-Verbose ('Building {0}...' -f $Package.MetaPackage.Name)
    $metaPackageFile = Build-ChocolateyPackage `
        -Package $Package.MetaPackage `
        -OutPath $OutPath `
        -ChocolateyPath $ChocolateyPath `
        -ScanFiles:$ScanFiles `
        -KeepFiles:$KeepFiles
    $packageFiles.Add($metaPackageFile) | Out-Null

    $packageFiles
}


<#
.SYNOPSIS
    Downloads a RemoteFile to its local path and optionally scans it for viruses
.DESCRIPTION
    Using the given RemoteFile object, downloads the contents at the url and
    saves it to the import path. If the Scan flag is set the file will
    automatically be scanned using Windows Defeneder. This function will throw
    an exception if the Scan flag is passed but Windows Defender is not
    available.
.PARAMETER RemoteFile
    The RemoteFile object to download
.PARAMETER OutPath
    The output path to download to. The final file location will be the given
    output path + the RemoteFile import path. For example, if the output path
    is 'C:\myfolder' and the import path is 'files\myfile.exe' then the final
    file path will be 'C:\myfolder\files\myfile.exe'.
.PARAMETER Scan
    Whether or not to scan the downloaded file using Windows Defender
.EXAMPLE
    Get-RemoteFile -RemoteFile $myFile -OutPath C:\myfolder -Scan
.OUTPUTS
    None
#>
Function Get-RemoteFile {
    param(
        [Parameter(
            Mandatory = $true,
            Position = 1,
            ValueFromPipeline = $true
        )]
        [RemoteFile] $File,
        [Parameter(
            Mandatory = $true,
            Position = 2
        )]
        [string] $OutPath,
        [switch] $Scan
    )
    
    $filePath = Join-Path $OutPath $File.ImportPath
    if (!(Test-Path (Split-Path $filePath))) {
        New-Item -ItemType Directory -Path (Split-Path $filePath)
    }

    Write-Verbose ('Downloading {0} to {1}...' -f $File.Url, $filePath)
    Invoke-WebRequest $File.Url -OutFile $filePath

    if ($File.Sha1) {
        Write-Verbose ('Computing file hash for {0}...' -f $filePath)
        $hash = Get-FileHash $filePath -Algorithm SHA1

        Write-Verbose ('Downloaded file hash: {0}' -f $hash.Hash)
        Write-Verbose ('Expected file hash: {0}' -f $File.Sha1)
        if ($File.Sha1 -ne $hash.Hash) {
            throw 'The downloaded file hash did not match the expected hash'
        }
    }

    if ($Scan) {
        Write-Verbose ('Scanning {0}...' -f $filePath)
        $exitCode = Invoke-WindowsDefenderScan $filePath

        if ($exitCode -ne 0) {
            throw '{0} was flagged by Windows Defender as dangerous' -f $filePath
        }
    }
}

<#
.SYNOPSIS
    Scans the given file using Windows Defender
.DESCRIPTION
    Executes MpCmdRun.exe and performs a custom scan against the given file, 
    returning the exit code of the process. 
.PARAMETER FilePath
    The path to the file the scan
.EXAMPLE
    $exitCode = Invoke-WindowsDefenderScan path\to\file.exe
.OUTPUTS
    The exit code of the scan process: 0 is safe, 2 is unsafe.
#>
Function Invoke-WindowsDefenderScan {
    param(
        [Parameter(
            Mandatory = $true
        )]
        [string] $FilePath
    )
    $mpCmd = Join-Path $env:ProgramFiles 'Windows Defender/MpCmdRun.exe' -ErrorAction SilentlyContinue
    if (!(Test-Path $mpCmd)) {
        throw 'Unable to locate Windows Defender at {0}' -f (Join-Path $env:ProgramFiles 'Windows Defender/MpCmdRun.exe')
    }

    $mpArgs = @(
        '-Scan',
        '-ScanType 3',
        '-File "{0}"' -f $FilePath
    )

    $proc = Start-Process $mpCmd -ArgumentList $mpArgs -PassThru -NoNewWindow -Wait
    $proc.ExitCode
}


<#
.SYNOPSIS
    Runs choco pack on the given NuSpec file
.DESCRIPTION
    Executes the Chocolatey binary, passing arguments for building the given
    NuSpec file at the given build path. The OutPath is also passed and
    instructs Chocolatey where to place the build artifacts.
.PARAMETER NuSpecFile
    The path to the NuSpec file
.PARAMETER BuildPath
    The path to the package contents
.PARAMETER OutPath
    The path where Chocolatey will output build artifacts
.PARAMETER ChocolateyPath
    The path to the choco binary - defaults to 'choco'
.EXAMPLE
    $exitCode = Invoke-ChocolateyBuild `
        -NuSpecFile 'C:\my\package.nuspec' `
        -BuildPath 'C:\my\' `
        -OutPath 'C:\my\bin'
.OUTPUTS
    The exit code of the Chocolatey build process
#>
Function Invoke-ChocolateyBuild {
    param(
        [string] $NuspecFile,
        [string] $BuildPath,
        [string] $OutPath,
        [string] $ChocolateyPath = 'choco'
    )

    $chocoArgs = @(
        'pack',
        $NuspecFile,
        '--outputdirectory {0}' -f $OutPath
    )

    Write-Verbose ("Executing `"{0} {1}`" in directory {2}" -f $ChocolateyPath, ($chocoArgs -join ' '), $OutPath)
    $proc = Start-Process $ChocolateyPath -ArgumentList $chocoArgs -WorkingDirectory $BuildPath -PassThru -NoNewWindow -Wait
    $proc.ExitCode
}

<#
.SYNOPSIS
    Creates a NuSpec file from the given object
.DESCRIPTION
    Given a package manifest, constructs the appropriate XML to create a valid
    NuSpec file and returns it as an XML document
.PARAMETER Manifest
    The PackageManifest object to construct from
.EXAMPLE
    New-ChocolateyNuSpec -Manifest $package.Manifest
.OUTPUTS
    A System.Xml.XmlDocument containing the NuSpec configuration
#>
Function New-ChocolateyNuSpec {
    [OutputType([System.Xml.XmlDocument])]
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true
        )]
        [PackageManifest] $Manifest
    )

    # Create root element
    [xml]$xml = New-Object System.Xml.XmlDocument
    $xml.AppendChild($xml.CreateXmlDeclaration('1.0', 'UTF-8', $null)) | Out-Null
    
    # Create package element
    $package = $xml.CreateNode('element', 'package', $null)
    $package.SetAttribute('xmlns', 'http://schemas.microsoft.com/packaging/2015/06/nuspec.xsd')

    # Create metadata element
    $metadata = $xml.CreateNode('element', 'metadata', $null)
    Add-PropertiesToNode $Manifest.Metadata $metadata -Ignore @('Dependencies') -Uncapitalize | Out-Null

    # Create metadata dependencies element if present
    if ($Manifest.Metadata.Dependencies) {
        $dependencies = $xml.CreateNode('element', 'dependencies', $null)
        foreach ($dependency in $Manifest.Metadata.Dependencies) {
            $dependencyNode = $xml.CreateNode('element', 'dependency', $null)
            Add-PropertiesToNode $dependency $dependencyNode -Uncapitalize -UseAttributes | Out-Null
            $dependencies.AppendChild($dependencyNode) | Out-Null
        }
        $metadata.AppendChild($dependencies) | Out-Null
    }
    $package.AppendChild($metadata) | Out-Null

    # Create files element if present
    if ($Manifest.Files) {
        $files = $xml.CreateNode('element', 'files', $null)
        foreach ($file in $Manifest.Files) {
            $fileNode = $xml.CreateNode('element', 'file', $null)
            Add-PropertiesToNode $file $fileNode -Uncapitalize -UseAttributes | Out-Null
            $files.AppendChild($fileNode) | Out-Null
        }
        $package.AppendChild($files) | Out-Null
    }

    $xml.AppendChild($package) | Out-Null
    $xml
}

<#
.SYNOPSIS
    Adds properties from the given object to the given XML node
.DESCRIPTION
    Iterates through all properties on the given object and assigns each
    property to a child element on the given node. If UseAttributes is passed
    then the properties are assigned to the given node as attributes instead.
.PARAMETER Object
    The object to copy properties from
.PARAMETER Node
    The XML node to add the properties to
.PARAMETER Ignore
    An array of property names to ignore and not add to the node
.PARAMETER UseAttributes
    Assigns the properties to the node as attributes instead of creating child
    elements.
.PARAMETER Uncapitalize
    Removes capitalization from the property names before adding them
.EXAMPLE
    Add-PropertiesToNode $object $objectNode -Uncapitalize -UseAttributes
.OUTPUTS
    The XML node passed in is modified in place
#>
Function Add-PropertiesToNode {
    param(
        [Parameter(
            Mandatory = $true,
            Position = 1
        )]
        [object] $Object,
        [Parameter(
            Mandatory = $true,
            Position = 2
        )]
        [System.Xml.XmlLinkedNode] $Node,
        [string[]] $Ignore = @(),
        [switch] $UseAttributes,
        [switch] $Uncapitalize
    )

    $properties = $Object | Get-Member | Where-Object MemberType -EQ 'Property' | Select-Object -ExpandProperty Name
    foreach ($property in $properties) {
        $propertyName = $property
        $propertyValue = $Object | Select-Object -ExpandProperty $property

        if ($propertyName -in $Ignore) {
            continue
        }

        if ($Uncapitalize) {
            $propertyName = $property.Insert(0, $property.Substring(0, 1).ToLower()).Remove(1, 1)
        }

        if ($UseAttributes) {
            $Node.SetAttribute($propertyName, $propertyValue) | Out-Null
        }
        else {
            $xmlProperty = $xml.CreateNode('element', $propertyName, $null)
            $xmlProperty.InnerText = $propertyValue
            $Node.AppendChild($xmlProperty) | Out-Null
        }
    }
}

<#
.SYNOPSIS
    Creates ignore files for all executables at the given path
.DESCRIPTION
    Recursively scans the given path for .exe files and, for each file found,
    creates an assocated .ignore file in the same location as the exe file.
    This prevents exe files from being automatically shimmed by Chocolatey.
.PARAMETER BuildPath
    The path to search and unshim files for
.EXAMPLE
    Invoke-Unshim C:\my\build\path
.OUTPUTS
    None
#>
Function Invoke-Unshim {
    param($BuildPath)

    $exeFiles = Get-ChildItem $BuildPath -Filter '*.exe' -Recurse
    foreach ($file in $exeFiles) {
        $ignoreFile = $file.FullName + '.ignore'

        Write-Verbose ('Preventing shim of {0} with {1}...' -f $file.FullName, $ignoreFile)
        Set-Content $ignoreFile ''
    }
}

<#
.SYNOPSIS
    Returns the contents of a ChocolateyInstall.ps1 file using the given ChocolateyPackage
.DESCRIPTION
    Using the built-in template, dynamically generates the contents of a 
    ChocolateyInstall.ps1 file for the given ChocolateyPackage. The contents of
    the file are returned. 
.PARAMETER Package
    The Chocolatey package to create the installer for
.EXAMPLE
    Set-Content 'ChocolateyInstall.ps1' (Build-InstallerFile $Package)
.OUTPUTS
    The contents of the ChocolateyInstall.ps1 file
#>
Function Build-InstallerFile {
    param(
        [ChocolateyPackage] $Package
    )

    $staticFilePath = Join-Path $PSScriptRoot '..\static'
    $installerTemplate = Join-Path $staticFilePath 'template\default\ChocolateyInstall.eps'
    $binding = @{
        packageName = $Package.Manifest.Metadata.Id
        filePath    = $Package.Installer.InstallerPath
        filePath64  = $Package.Installer.InstallerPath64
        fileType    = $Package.Installer.InstallerType
        exitCodes   = $Package.Installer.ExitCodes
        flags       = $Package.Installer.Flags
        arguments   = $Package.Installer.Arguments
    }

    Invoke-EpsTemplate -Path $installerTemplate -Safe -Binding $binding
}

<#
.SYNOPSIS
    Returns the contents of a ChocolateyInstall.ps1 file using the given ChocolateyISOPackage
.DESCRIPTION
    Using the built-in template, dynamically generates the contents of a 
    ChocolateyInstall.ps1 file for the given ChocolateyISOPackage. The contents 
    of the file are returned. 
.PARAMETER Package
    The Chocolatey ISO package to create the installer for
.EXAMPLE
    Set-Content 'ChocolateyInstall.ps1' (Build-ISOInstallerFile $Package)
.OUTPUTS
    The contents of the ChocolateyInstall.ps1 file
#>
Function Build-ISOInstallerFile {
    param(
        [ChocolateyISOPackage] $Package
    )

    $staticFilePath = Join-Path $PSScriptRoot '..\static'
    $installerTemplate = Join-Path $staticFilePath 'template\iso\ChocolateyInstall.eps'
    $binding = @{
        packageName = $Package.Manifest.Metadata.Id
        filePath    = $Package.IsoFile.ImportPath
        url         = $Package.IsoFile.Url
        hash        = $Package.IsoFile.Sha1
    }

    Invoke-EpsTemplate -Path $installerTemplate -Safe -Binding $binding
}