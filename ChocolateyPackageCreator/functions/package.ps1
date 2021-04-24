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
    $config.processScript = Join-Path $PackagePath $config.processScript

    $config.manifest = @{
        metadata     = New-Object PackageMetadata -Property $config.manifest.metadata
        dependencies = $config.manifest.dependencies.ForEach( {
                New-Object PackageDependency -Property $_
            })
        files        = $config.manifest.files.ForEach( {
                New-Object PackageFile -Property $_
            })
    }
    $config.localFiles = $config.localFiles.ForEach( {
            New-Object LocalFile -Property $_
        })
    $config.remoteFiles = $config.remoteFiles.ForEach( {
            New-Object RemoteFile -Property $_
        })

    New-Object ChocolateyPackage -Property $config
}

<#
.SYNOPSIS
    Creates an example package configuration structure at the given path
.DESCRIPTION
    Creates an example package configuration file along with an example process
    and Chocolatey install file at the given path. This is the easiest way to
    get started with making a new package.
.PARAMETER PackagePath
    The full file path to where the package files will be created
.EXAMPLE
    New-ChocolateyPackageConfig C:\my\package
.OUTPUTS
    None
#>
Function New-ChocolateyPackageConfig {
    param(
        [string] $PackagePath
    )

    if (!(Test-Path $PackagePath)) {
        Write-Verbose ('Creating {0}...' -f $PackagePath)
        New-Item -ItemType Directory $PackagePath | Out-Null
    }

    $packageFiles = Join-Path $PSScriptRoot '..\static'
    Write-Verbose ('Copying package files from {0} to {1}...' -f $packageFiles, $PackagePath)
    Copy-Item (Join-Path $packageFiles '*') $PackagePath -Recurse | Out-Null
}

Function Test-PackageConfiguration {
    param(
        [hashtable] $Configuration
    )

    Test-ConfigSection -Object ([ChocolateyPackage]::new()) -Properties $Configuration.Keys
    foreach ($property in $Configuration.GetEnumerator()) {
        switch ($property.Name) {
            Manifest {
                Test-ConfigSection -Object ([PackageManifest]::new()) -Properties $property.Value.Keys

                if (!($property.Value.metadata -is [hashtable])) {
                    throw 'Error validating package configuration: metadata property must be a hashtable'
                }
                Test-ConfigSection -Object ([PackageMetadata]::new()) -Properties $property.Value.metadata.Keys

                if (!($property.Value.dependencies -is [array])) {
                    throw 'Error validating package configuration: dependencies property must be an array'
                }
                foreach ($dependency in $property.Value.dependencies) {
                    Test-ConfigSection -Object ([PackageDependency]::new()) -Properties $dependency.Keys
                }

                if (!($property.Value.files -is [array])) {
                    throw 'Error validating package configuration: files property must be an array'
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