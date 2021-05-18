$TYPES = @(
    'PackageManifest',
    'PackageMetadata',
    'PackageDependency',
    'PackageFile',
    'LocalFile',
    'RemoteFile',
    'PackageInstaller'
)

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

    # Add package path, meta package, and packages
    $config.Add('path', $PackagePath)
    $config.Add('metapackage', $MetaPackage)
    $config.Add('packages', $Packages)

    # Convert configuration to object
    $packageSchema = Get-Schema 'ChocolateyISOPackage'
    Invoke-Schema $packageSchema $config 'ChocolateyISOPackage' $TYPES
}

<#
.SYNOPSIS
    Returns a ChocolateyPackage object using the given configuration
.DESCRIPTION
    Validates the given package configuration data and then creates a new
    ChocolateyPackage object from the configuration data. 
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

    # Add package path and fully qualify local file paths
    $config.Add('path', $PackagePath)
    foreach ($localFile in $config.localFiles) {
        $localFile.localPath = Join-Path $config.Path $localFile.localPath
    }
    if ($config.processScript) {
        $config.processScript = Join-Path $config.Path $config.processScript
    }

    # Convert configuration to object
    $packageSchema = Get-Schema 'ChocolateyPackage'
    Invoke-Schema $packageSchema $config 'ChocolateyPackage' $TYPES
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

<#
.SYNOPSIS
    Loads the schema file for the given custom object type
.DESCRIPTION
    Searches in the module schema directory ($MODULEROOT\schema) for a schema
    file for the given custom object type. It assumes a .PSD1 file with the name
    of the object type will exist in the schema directory and will automatically
    import the contents and return them.
.PARAMETER Name
    The name of the custom object to load the schema for
.EXAMPLE
    $schema = Get-Schema ChocolateyPackage
.OUTPUTS
    A hashtable containing the imported contents of the schema file 
#>
Function Get-Schema {
    param(
        [string] $Name
    )

    $schemaFile = Join-Path $PSScriptRoot ('..\schema\{0}.psd1' -f $Name)
    if (!(Test-Path $schemaFile)) {
        throw ('Could not find schema file for {0} at {1}' -f $Name, $schemaFile)
    }

    Import-PowerShellDataFile $schemaFile
}

<#
.SYNOPSIS
    Applies the given schema against the given input object
.DESCRIPTION
    The given input object is first validated against the schema and then any
    custom types are converted from their hashtable values to their respective
    object type. Optional properties that are not present in the input object
    have the default value contained in the schema applied to them. Only the
    custom types contained in the $CustomTypes parameter are automaticaly
    converted, the remaining types are left as is after validation. This
    function is recursive and will operate down the tree of an object performing
    validation and conversion on all applicable properties.
.PARAMETER Name
    The schema to apply to the input object
.PARAMETER InputObject
    The object to validate and transform
.PARAMETER InputObjectType
    The type of the input object (used for conversion)
.PARAMETER CustomTypes
    A list of types to validate and transform. Each type in the list must have
    a schema file located in the schema directory.
.EXAMPLE
    $transformedObject = Invoke-Schema $mySchema $object 'MyObjectType' @('CustomObjectType')
.OUTPUTS
    The validated and transformed input object
#>
Function Invoke-Schema {
    param(
        [hashtable] $Schema,
        [hashtable] $InputObject,
        [string] $InputObjectType,
        [string[]] $CustomTypes
    )

    $InputObject = $InputObject.Clone()

    foreach ($property in $InputObject.GetEnumerator()) {
        if (!($property.Name -in $Schema.Keys)) {
            throw ('Error validating configuration: {0} does not have a {1} property' -f $InputObjectType, $property.Name)
        }
    }

    foreach ($property in $Schema.GetEnumerator()) {
        if (($property.Value.required) -and (!($property.Name -in $InputObject.Keys))) {
            throw ('Error validating configuration: {0} must have a {1} property' -f $InputObjectType, $property.Name)
        }

        if (!($property.Value.Required) -and (!($property.Name -in $InputObject.Keys))) {
            $InputObject.Add($property.Name, $property.Value.default)
        }

        if ($property.Value.type -match '\[\]') {
            $inputType = $InputObject[$property.Name].GetType()
            if (!(($inputType.Name -eq 'ArrayList') -or ($inputType.BaseType.Name -eq 'Array'))) {
                throw ('Error validating configuration: {0} property of {1} must be an array' -f $property.Name, $InputObjectType)
            }

            $type = $property.Value.type -replace '\[\]', ''
            if ($type -in $CustomTypes) {
                foreach ($subObject in $InputObject[$property.Name]) {
                    $InputObject[$property.Name] = $InputObject[$property.Name].Clone()
                    $index = $InputObject[$property.Name].IndexOf($subObject)
                    
                    $propertySchema = Get-Schema $type
                    $InputObject[$property.Name][$index] = Invoke-Schema $propertySchema $subObject $type $CustomTypes
                }
            }
        }
        else {
            if ($property.Value.type -in $CustomTypes) {
                if (($property.Value.required) -and ($InputObject[$property.Name].Count -eq 0)) {
                    throw ('Error validating configuration: {0} property of {1} cannot be empty' -f $property.Name, $InputObjectType)
                }

                if ($InputObject[$property.Name].Count -gt 0) {
                    $propertySchema = Get-Schema $property.Value.type
                    $InputObject[$property.Name] = Invoke-Schema $propertySchema $InputObject[$property.Name] $property.Value.type $CustomTypes
                }
            }
        }
    }

    if ($InputObject.GetType() -ne $InputObjectType) {
        New-Object $InputObjectType -Property $InputObject
    }
    else {
        $InputObject
    }
}