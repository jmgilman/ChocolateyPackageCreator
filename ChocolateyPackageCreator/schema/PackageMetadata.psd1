@{
    Id                       = @{
        type     = 'string'
        required = $true
    }
    Title                    = @{
        type     = 'string'
        required = $true
    }
    Version                  = @{
        type     = 'string'
        required = $true
    }
    Authors                  = @{
        type     = 'string'
        required = $true
    }
    Owners                   = @{
        type     = 'string'
        required = $true
    }
    Summary                  = @{
        type     = 'string'
        required = $true
    }
    Description              = @{
        type     = 'string'
        required = $true
    }
    ProjectUrl               = @{
        type     = 'string'
        required = $true
    }
    PackageSourceUrl         = @{
        type     = 'string'
        required = $true
    }
    Tags                     = @{
        type     = 'string'
        required = $true
    }
    Copyright                = @{
        type     = 'string'
        required = $true
    }
    LicenseUrl               = @{
        type     = 'string'
        required = $true
    }
    RequireLicenseAcceptance = @{
        type     = 'string'
        required = $true
    }
    Dependencies             = @{
        type     = 'PackageDependency[]'
        required = $false
        default  = @()
    }
}