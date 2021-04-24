@{
    name          = 'mypackage'
    processScript = 'process.ps1'
    shim          = $False
    localFiles    = @(
        @{
            localPath  = 'files/ChocolateyInstall.ps1'
            importPath = 'tools/ChocolateyInstall.ps1'
        }
    )
    remoteFiles   = @(
        @{
            url        = 'https://my.download.com/installer.msi'
            sha1       = ''
            importPath = 'tools/installer.msi'
        }
    )
    manifest      = @{
        metadata     = @{
            id                       = 'mypackage'
            title                    = 'My Package'
            version                  = '1.0.0'
            authors                  = 'Author'
            owners                   = 'Owners'
            summary                  = 'Installs My Package'
            description              = 'My package does x y z'
            projectUrl               = 'https://www.mypackage.com'
            packageSourceUrl         = 'https://github.com/me/mypackagesource'
            tags                     = 'my package'
            copyright                = '2021 Authors'
            licenseUrl               = 'https://www.mypackage.com/license'
            requireLicenseAcceptance = 'false'
        }
        dependencies = @()
        files        = @(
            @{
                source = 'tools\**'
                target = 'tools'
            }
        )
    }
}