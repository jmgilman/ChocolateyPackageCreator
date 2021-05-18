@{
    Name          = @{
        type     = 'string'
        required = $true
    }
    Path          = @{
        type     = 'string'
        required = $true
    }
    ProcessScript = @{
        type     = 'string'
        required = $false
        default  = ''
    }
    Shim          = @{
        type     = 'bool'
        required = $false
        default  = $false
    }
    Installer     = @{
        type     = 'PackageInstaller'
        required = $false
        default  = @{}
    }
    LocalFiles    = @{
        type     = 'LocalFile[]'
        required = $false
        default  = @()
    }
    RemoteFiles   = @{
        type     = 'RemoteFile[]'
        required = $false
        default  = @()
    }
    Manifest      = @{
        type     = 'PackageManifest'
        required = $true
    }
}