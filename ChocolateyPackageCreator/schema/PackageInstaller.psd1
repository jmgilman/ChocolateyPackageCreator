@{
    ScriptPath      = @{
        type     = 'string'
        required = $true
    }
    InstallerPath   = @{
        type     = 'string'
        required = $true
    }
    InstallerPath64 = @{
        type     = 'string'
        required = $false
        default  = ''
    }
    InstallerType   = @{
        type     = 'string'
        required = $true
    }
    ExitCodes       = @{
        type     = 'int[]'
        required = $false
        default  = @(0)
    }
    Flags           = @{
        type     = 'string'
        required = $false
        default  = ''
    }
    ArgumentPrefix  = @{
        type     = 'string'
        required = $false
        default  = ''
    }
    Arguments       = @{
        type     = 'hashtable'
        required = $false
        default  = @{}
    }
}