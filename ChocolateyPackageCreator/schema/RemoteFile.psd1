@{
    Url        = @{
        type     = 'string'
        required = $true
    }
    Sha1       = @{
        type     = 'string'
        required = $false
        default  = ''
    }
    ImportPath = @{
        type     = 'string'
        required = $true
    }
}