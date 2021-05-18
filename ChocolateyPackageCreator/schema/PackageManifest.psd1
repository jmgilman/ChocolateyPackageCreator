@{
    Metadata = @{
        type     = 'PackageMetadata'
        required = $true
    }
    Files    = @{
        type     = 'PackageFile[]'
        required = $false
        default  = @()
    }
}