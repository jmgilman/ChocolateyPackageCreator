@{
    Name        = @{
        type     = 'string'
        required = $true
    }
    Path        = @{
        type     = 'string'
        required = $true
    }
    IsoFile     = @{
        type     = 'RemoteFile'
        required = $true
    }
    Manifest    = @{
        type     = 'PackageManifest'
        required = $true
    }
    MetaPackage = @{
        type     = 'ChocolateyPackage'
        required = $true
    }
    Packages    = @{
        type     = 'ChocolateyPackage[]'
        required = $true
    }
}