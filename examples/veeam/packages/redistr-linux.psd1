@{
    name          = 'veeam-redistr-windows'
    processScript = ''
    shim          = $False
    installer     = @{
        scriptPath      = 'tools'
        installerPath   = 'Packages\VAWRedist.msi'
        installerPath64 = ''
        installerType   = 'msi'
        exitCodes       = @(0, 1638, 1641, 3010)
        flags           = '/qn /norestart'
        argumentPrefix  = ''
        arguments       = @{
            ACCEPT_EULA                = '1'
            ACCEPT_THIRDPARTY_LICENSES = '1'
        }
    }
    localFiles    = @()
    remoteFiles   = @()
    manifest      = @{
        metadata = @{
            id                       = 'veeam-redistr-windows'
            title                    = 'Redistributable Package for Veeam Agent for Microsoft Windows'
            version                  = '11.0.0.837'
            authors                  = 'Veeam'
            owners                   = 'Joshua Gilman'
            summary                  = 'Installs the Redistributable Package for Veeam Agent for Microsoft Windows'
            description              = 'Veeam Backup & Replication is a backup solution developed for VMware vSphere and Microsoft Hyper-V virtual environments. Veeam Backup & Replication provides a set of features for performing data protection and disaster recovery tasks.'
            projectUrl               = 'http://www.veeam.com/'
            packageSourceUrl         = 'https://github.com/jmgilman/ChocolateyPackageManager'
            tags                     = 'veeam backup replication redistrutable agent windows'
            copyright                = '2021 Veeam'
            licenseUrl               = 'https://www.veeam.com/eula.html'
            requireLicenseAcceptance = 'false'
            dependencies             = @(
                @{
                    id      = 'veeam-iso'
                    version = '[11.0.0.837]'
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