@{
    name          = 'veeam-console'
    processScript = ''
    shim          = $False
    installer     = @{
        scriptPath      = 'tools'
        installerPath   = 'Backup/Shell.x64.msi'
        installerPath64 = ''
        installerType   = 'msi'
        exitCodes       = @(0, 1638, 1641, 3010)
        flags           = '/qn /norestart'
        argumentPrefix  = ''
        arguments       = @{
            ACCEPTEULA                 = 'yes'
            ACCEPT_THIRDPARTY_LICENSES = '1'
            INSTALLDIR                 = ''
        }
    }
    localFiles    = @()
    remoteFiles   = @()
    manifest      = @{
        metadata = @{
            id                       = 'veeam-console'
            title                    = 'Veeam Backup & Replication Console'
            version                  = '11.0.0.837'
            authors                  = 'Veeam'
            owners                   = 'Joshua Gilman'
            summary                  = 'Installs the Veeam Backup & Replication Console'
            description              = 'Veeam Backup & Replication is a backup solution developed for VMware vSphere and Microsoft Hyper-V virtual environments. Veeam Backup & Replication provides a set of features for performing data protection and disaster recovery tasks.'
            projectUrl               = 'http://www.veeam.com/'
            packageSourceUrl         = 'https://github.com/jmgilman/ChocolateyPackageManager'
            tags                     = 'veeam backup replication console'
            copyright                = '2021 Veeam'
            licenseUrl               = 'https://www.veeam.com/eula.html'
            requireLicenseAcceptance = 'false'
            dependencies             = @(
                @{
                    id      = 'veeam-iso'
                    version = '[11.0.0.837]'
                },
                @{
                    id      = 'dotnet-472'
                    version = ''
                },
                @{
                    id      = 'ms-reportviewer2015'
                    version = ''
                },
                @{
                    id      = 'sql-2014-smo'
                    version = ''
                }
            )
        }
        files    = @(
            @{
                src    = 'tools\**'
                target = 'tools'
            }
        )
    }
}