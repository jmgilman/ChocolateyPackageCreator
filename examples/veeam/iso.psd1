@{
    name          = 'veeam-iso'
    processScript = ''
    shim          = $False
    installer     = @{}
    localFiles    = @()
    remoteFiles   = @(
        @{
            url        = 'https://download2.veeam.com/VBR/v11/VeeamBackup&Replication_11.0.0.837_20210220.iso'
            sha1       = ''
            importPath = 'tools/veeam.iso'
        }
    )
    manifest      = @{
        metadata = @{
            id                       = 'veeam-iso'
            title                    = 'Veeam Backup & Replication ISO'
            version                  = '11.0.0.837'
            authors                  = 'Veeam'
            owners                   = 'Joshua Gilman'
            summary                  = 'Installs the contents of the Veeam Backup & Replication ISO'
            description              = 'Veeam Backup & Replication is a backup solution developed for VMware vSphere and Microsoft Hyper-V virtual environments. Veeam Backup & Replication provides a set of features for performing data protection and disaster recovery tasks.'
            projectUrl               = 'http://www.veeam.com/'
            packageSourceUrl         = 'https://github.com/jmgilman/ChocolateyPackageManager'
            tags                     = 'veeam backup replication iso'
            copyright                = '2021 Veeam'
            licenseUrl               = 'https://www.veeam.com/eula.html'
            requireLicenseAcceptance = 'false'
            dependencies             = @()
        }
        files    = @(
            @{
                src    = 'tools\**'
                target = 'tools'
            }
        )
    }
}