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
        [string] $ChocolateyPath = 'choco',
        [switch] $ScanFiles,
        [switch] $KeepFiles
    )

    Write-Verbose 'Creating build directory...'
    $buildDir = Join-Path $OutPath 'build'
    New-Item -ItemType Directory $buildDir

    Write-Verbose 'Creating NuSpec file...'
    $xml = New-ChocolateyNuSpec $Package.Manifest
    $nuspecPath = (Join-Path $buildDir ($Package.Manifest.Metadata.Id + '.nuspec'))
    $xml.Save($nuspecPath)

    if ($Package.RemoteFiles) {
        Write-Verbose 'Downloading remote files...'
        foreach ($remoteFile in $Package.RemoteFiles) {
            if ($ScanFiles) {
                $remoteFile | Get-RemoteFile -OutPath $buildDir -Scan
            }
            else {
                $remoteFile | Get-RemoteFile -OutPath $buildDir
            }
        }
    }

    if ($Package.LocalFiles) {
        Write-Verbose 'Copying local files...'
        foreach ($localFile in $Package.LocalFiles) {
            $outFile = Join-Path $buildDir $localFile.ImportPath
            if (!(Test-Path (Split-Path $outFile))) {
                New-Item -ItemType Directory -Path (Split-Path $outFile)
            }

            Write-Verbose ('Copying {0} to {1}...' -f $localFile.LocalPath, $outFile)
            Copy-Item $localFile.LocalPath $outFile
        }
    }

    if ($Package.processScript) {
        $proc = Get-Command $Package.processScript | Select-Object -ExpandProperty ScriptBlock
        $proc.Invoke($buildDir)
    }

    Write-Verbose 'Building package...'
    $chocoArgs = @(
        'pack',
        $nuspecPath,
        '--outputdirectory {0}' -f $OutPath
    )

    Write-Verbose ("Executing `"{0} {1}`" in directory {2}" -f 'choco', ($chocoArgs -join ' '), $OutPath)
    $proc = Start-Process $ChocolateyPath -ArgumentList $chocoArgs -WorkingDirectory $buildDir -PassThru -NoNewWindow -Wait

    if ($proc.ExitCode -ne 0) {
        throw 'The Chocolatey package process exited with non-zero exit code: {0}' -f $proc.ExitCode
    }

    if (!$KeepFiles) {
        Write-Verbose 'Cleaning up...'
        Remove-Item $buildDir -Recurse
    }
    
    $packageName = '{0}.{1}.nupkg' -f $Package.Manifest.Metadata.Id, $Package.Manifest.Metadata.Version
    Join-Path $OutPath $packageName
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

    [xml]$xml = New-Object System.Xml.XmlDocument
    $xml.AppendChild($xml.CreateXmlDeclaration('1.0', 'UTF-8', $null)) | Out-Null
    
    $package = $xml.CreateNode('element', 'package', $null)
    $package.SetAttribute('xmlns', 'http://schemas.microsoft.com/packaging/2015/06/nuspec.xsd')

    $metadata = $xml.CreateNode('element', 'metadata', $null)
    $metadataProperties = $Manifest.Metadata | Get-Member | Where-Object MemberType -EQ 'Property' | Select-Object -ExpandProperty Name
    foreach ($property in $metadataProperties) {
        $propertyName = $property.Insert(0, $property.Substring(0, 1).ToLower()).Remove(1, 1) # Uncapitalize
        $xmlProperty = $xml.CreateNode('element', $propertyName, $null)
        $xmlProperty.InnerText = $Manifest.Metadata | Select-Object -ExpandProperty $property
        $metadata.AppendChild($xmlProperty) | Out-Null
    }
    $package.AppendChild($metadata) | Out-Null

    if ($Manifest.Dependencies) {
        $dependencies = $xml.CreateNode('element', 'dependencies', $null)
        foreach ($dep in $Manifest.Dependencies) {
            $xmlDep = $xml.CreateNode('element', 'dependency', $null)
            $xmlDep.SetAttribute('id', $dep.Id)
            $xmlDep.SetAttribute('version', $dep.Version)
            $dependencies.AppendChild($xmlDep) | Out-Null
        }
        $metadata.AppendChild($dependencies) | Out-Null
    }

    if ($Manifest.Files) {
        $files = $xml.CreateNode('element', 'files', $null)
        foreach ($file in $Manifest.Files) {
            $xmlFile = $xml.CreateNode('element', 'file', $null)
            $xmlFile.SetAttribute('src', $file.Source)
            $xmlFile.SetAttribute('target', $file.Target)
            $files.AppendChild($xmlFile) | Out-Null
        }
        $package.AppendChild($files) | Out-Null
    }

    $xml.AppendChild($package) | Out-Null
    $xml
}