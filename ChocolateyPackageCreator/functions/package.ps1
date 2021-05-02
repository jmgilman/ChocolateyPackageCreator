<#
.SYNOPSIS
    Returns a ChocolateyISOPackage object using the given packages
.DESCRIPTION
    Returns a ChocolateyISOPackage object using the given packages. Each package
    is validated before it is created. 
.PARAMETER PackagePath
    The full file path to where the ISO package files are located
.PARAMETER PackageConfig
    The package configuration data to use when creating the ChocolateyISOPackage
.PARAMETER MetaPackage
    The meta package which ties the ISO and all sub-packages together
.PARAMETER Packages
    A list of packages which are subordinate and require use of the ISO file
    contents
.EXAMPLE
    $package = New-ChocolateyISOPackage `
        -PackagePath 'C:\my\package' `
        -PackageConfig $myConfig `
        -MetaPackage $MetaPackae `
        -Packages @($Package1, $Package2, $Package3)
.OUTPUTS
    A new instance of the ChocolateyISOPackage object
#>
Function New-ChocolateyISOPackage {
    param(
        [string] $PackagePath,
        [hashtable] $PackageConfig,
        [ChocolateyPackage] $MetaPackage,
        [ChocolateyPackage[]] $Packages
    )

    # Clone config to prevent modifying passed in hash table
    $config = $PackageConfig.Clone()

    # Add package path, meta package, and packages, then validate configuration
    $config.Add('path', $PackagePath)
    $config.Add('metapackage', $MetaPackage)
    $config.Add('packages', $Packages)
    Test-ISOPackageConfiguration -Configuration $config

    $config.IsoFile = New-Object RemoteFile -Property $config.IsoFile
    $config.manifest.metadata.dependencies = $config.manifest.metadata.dependencies.ForEach( {
            New-Object PackageDependency -Property $_
        })
    $config.manifest = @{
        metadata = New-Object PackageMetadata -Property $config.manifest.metadata
        files    = $config.manifest.files.ForEach( {
                New-Object PackageFile -Property $_
            })
    }
    New-Object ChocolateyISOPackage -Property $config
}

<#
.SYNOPSIS
    Returns a ChocolateyPackage object using the given configuration
.DESCRIPTION
    Validates the given package configuration data and then creates a new
    ChocolateyPackage object from the configuration data. The validation is
    strict, meaning all configuration properties must be present and no
    erroneous properties may be present. 
.PARAMETER PackagePath
    The full file path to where the package files are located
.PARAMETER PackageConfig
    The package configuration data to use when creating the ChocolateyPackage
    object
.EXAMPLE
    $package = New-ChocolateyPackage `
        -PackagePath 'C:\my\package' `
        -PackageConfig $myConfig
.OUTPUTS
    A new instance of the ChocolateyPackage object
#>
Function New-ChocolateyPackage {
    param(
        [string] $PackagePath,
        [hashtable] $PackageConfig
    )

    # Clone config to prevent modifying passed in hash table
    $config = $PackageConfig.Clone()

    # Add package path and then validate configuration
    $config.Add('path', $PackagePath)
    Test-PackageConfiguration -Configuration $config

    # Fully qualify local file paths
    foreach ($localFile in $config.localFiles) {
        $localFile.localPath = Join-Path $PackagePath $localFile.localPath
    }
    if ($config.processScript) {
        $config.processScript = Join-Path $PackagePath $config.processScript
    }

    # Build ChocolateyPackage object from configuration data
    $config.manifest.metadata.dependencies = $config.manifest.metadata.dependencies.ForEach( {
            New-Object PackageDependency -Property $_
        })
    $config.manifest = @{
        metadata = New-Object PackageMetadata -Property $config.manifest.metadata
        files    = $config.manifest.files.ForEach( {
                New-Object PackageFile -Property $_
            })
    }
    $config.localFiles = $config.localFiles.ForEach( {
            New-Object LocalFile -Property $_
        })
    $config.remoteFiles = $config.remoteFiles.ForEach( {
            New-Object RemoteFile -Property $_
        })
    
    if ($config.installer) {
        $config.installer = New-Object PackageInstaller -Property $config.installer
    }

    New-Object ChocolateyPackage -Property $config
}

<#
.SYNOPSIS
    Creates an example package configuration structure at the given path
.DESCRIPTION
    Creates an example package configuration file along with an example process
    and Chocolatey install file at the given path. This is the easiest way to
    get started with making a new package.
.PARAMETER OutPath
    The full file path to where the package files will be created
.EXAMPLE
    New-ChocolateyPackageConfig C:\my\package
.OUTPUTS
    None
#>
Function New-ChocolateyPackageConfig {
    param(
        [string] $OutPath
    )

    if (!(Test-Path $OutPath)) {
        Write-Verbose ('Creating {0}...' -f $OutPath)
        New-Item -ItemType Directory $OutPath | Out-Null
    }

    $packageFile = Join-Path $PSScriptRoot '..\static\package.psd1'
    Write-Verbose ('Copying package file from {0} to {1}...' -f $packageFile, $OutPath)
    Copy-Item $packageFile $OutPath | Out-Null
}

Function Test-ISOPackageConfiguration {
    param(
        [hashtable] $Configuration
    )
    Test-ConfigSection -Object ([ChocolateyISOPackage]::new()) -Properties $Configuration.Keys
    foreach ($property in $Configuration.GetEnumerator()) {
        switch ($property.Name) {
            IsoFile {
                Test-ConfigSection -Object ([RemoteFile]::new()) -Properties $property.Value.Keys
            }
            Manifest {
                Test-ConfigSection -Object ([PackageManifest]::new()) -Properties $property.Value.Keys

                if (!($property.Value.metadata -is [hashtable])) {
                    throw 'Error validating package configuration: metadata property must be a hashtable'
                }
                Test-ConfigSection -Object ([PackageMetadata]::new()) -Properties $property.Value.metadata.Keys

                foreach ($dependency in $property.Value.metadata.dependencies) {
                    Test-ConfigSection -Object ([PackageDependency]::new()) -Properties $dependency.Keys
                }

                foreach ($file in $property.Value.files) {
                    Test-ConfigSection -Object ([PackageFile]::new()) -Properties $file.Keys
                }
            }
        }
    }
}

Function Test-PackageConfiguration {
    param(
        [hashtable] $Configuration
    )

    Test-ConfigSection -Object ([ChocolateyPackage]::new()) -Properties $Configuration.Keys
    foreach ($property in $Configuration.GetEnumerator()) {
        switch ($property.Name) {
            Installer {
                # This property is optional
                if ($Configuration['Installer'].Count -gt 0) {
                    Test-ConfigSection -Object ([PackageInstaller]::new()) -Properties $property.Value.Keys
                }
            }
            Manifest {
                Test-ConfigSection -Object ([PackageManifest]::new()) -Properties $property.Value.Keys

                if (!($property.Value.metadata -is [hashtable])) {
                    throw 'Error validating package configuration: metadata property must be a hashtable'
                }
                Test-ConfigSection -Object ([PackageMetadata]::new()) -Properties $property.Value.metadata.Keys

                foreach ($dependency in $property.Value.metadata.dependencies) {
                    Test-ConfigSection -Object ([PackageDependency]::new()) -Properties $dependency.Keys
                }

                foreach ($file in $property.Value.files) {
                    Test-ConfigSection -Object ([PackageFile]::new()) -Properties $file.Keys
                }
            }
            LocalFiles {
                if (!($property.Value -is [array])) {
                    throw 'Error validating package configuration: localFiles property must be an array'
                }
                foreach ($file in $property.Value) {
                    Test-ConfigSection -Object ([LocalFile]::new()) -Properties $file.Keys
                }
            }
            RemoteFiles {
                if (!($property.Value -is [array])) {
                    throw 'Error validating package configuration: remoteFiles property must be an array'
                }
                foreach ($file in $property.Value) {
                    Test-ConfigSection -Object ([RemoteFile]::new()) -Properties $file.Keys
                }
            }
        }
    }
}

Function Test-ConfigSection {
    param(
        [object] $Object,
        [string[]] $Properties
    )

    $objectProperties = $Object | Get-Member | Where-Object MemberType -EQ 'Property' | Select-Object -ExpandProperty Name
    foreach ($property in $Properties) {
        if (!($property -in $objectProperties)) {
            throw 'Error validating package configuration: Object of type {0} does not contain a property with name {1}' -f $Object.GetType().Name, $property
        }
    }

    foreach ($property in $objectProperties) {
        if (!($property -in $Properties)) {
            throw 'Error validating package configuration: Configuration is missing property {0} for object {1}' -f $property, $Object.GetType().Name
        }
    }
}