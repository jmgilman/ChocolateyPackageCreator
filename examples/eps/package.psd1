@{
    name          = 'eps'
    processScript = 'process.ps1'
    shim          = $False
    localFiles    = @()
    remoteFiles   = @(
        @{
            url        = 'https://github.com/straightdave/eps/archive/refs/tags/v1.0.0.zip'
            sha1       = ''
            importPath = 'extensions/eps.zip'
        }
    )
    manifest      = @{
        metadata = @{
            id                       = 'eps.extension'
            title                    = 'EPS'
            version                  = '1.0.0'
            authors                  = 'Dave Wu'
            owners                   = 'Joshua Gilman'
            summary                  = 'Installs EPS Powershell module'
            description              = 'EPS ( Embedded PowerShell ), inspired by ERB, is a templating tool that embeds PowerShell code into a text document. It is conceptually and syntactically similar to ERB for Ruby or Twig for PHP.'
            projectUrl               = 'https://github.com/straightdave/eps'
            packageSourceUrl         = 'https://github.com/jmgilman/ChocolateyPackageCreator'
            tags                     = 'powershell eps extension'
            copyright                = '2021 Dave Wu'
            licenseUrl               = 'https://github.com/straightdave/eps/blob/master/LICENSE'
            requireLicenseAcceptance = 'false'
            dependencies             = @()
        }
        files    = @(
            @{
                src    = 'extensions\**'
                target = 'extensions'
            }
        )
    }
}