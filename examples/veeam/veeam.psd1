@{
    name          = 'veeam'
    processScript = ''
    shim          = $False
    installer     = @{}
    localFiles    = @()
    remoteFiles   = @()
    manifest      = @{
        metadata = @{
            id                       = 'veeam'
            title                    = 'Veeam Backup & Replication'
            version                  = '11.0.0.837'
            authors                  = 'Veeam'
            owners                   = 'Joshua Gilman'
            summary                  = 'Installs Veeam Backup & Replication'
            description              = 'Veeam Backup & Replication is a backup solution developed for VMware vSphere and Microsoft Hyper-V virtual environments. Veeam Backup & Replication provides a set of features for performing data protection and disaster recovery tasks.'
            projectUrl               = 'http://www.veeam.com/'
            packageSourceUrl         = 'https://github.com/jmgilman/ChocolateyPackageManager'
            tags                     = 'veeam backup replication'
            copyright                = '2021 Veeam'
            licenseUrl               = 'https://www.veeam.com/eula.html'
            requireLicenseAcceptance = 'false'
            dependencies             = @(
                @{
                    id      = 'veeam-catalog'
                    version = '[11.0.0.837]'
                },
                @{
                    id      = 'veeam-server'
                    version = '[11.0.0.837]'
                },
                @{
                    id      = 'veeam-console'
                    version = '[11.0.0.837]'
                },
                @{
                    id      = 'veeam-explorer-ad'
                    version = '[11.0.0.837]'
                },
                @{
                    id      = 'veeam-explorer-exchange'
                    version = '[11.0.0.837]'
                },
                @{
                    id      = 'veeam-explorer-oracle'
                    version = '[11.0.0.837]'
                },
                @{
                    id      = 'veeam-explorer-sharepoint'
                    version = '[11.0.0.837]'
                },
                @{
                    id      = 'veeam-explorer-sql'
                    version = '[11.0.0.837]'
                },
                @{
                    id      = 'veeam-redistr-windows'
                    version = '[11.0.0.837]'
                },
                @{
                    id      = 'veeam-redistr-linux'
                    version = '[11.0.0.837]'
                },
                @{
                    id      = 'veeam-redistr-mac'
                    version = '[11.0.0.837]'
                }
            )
        }
        files    = @()
    }
}