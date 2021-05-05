@{
    name          = 'veeam-enterprise'
    processScript = ''
    shim          = $False
    installer     = @{
        scriptPath      = 'tools'
        installerPath   = 'EnterpriseManager\BackupWeb_x64.msi'
        installerPath64 = ''
        installerType   = 'msi'
        exitCodes       = @(0, 1638, 1641, 3010)
        flags           = '/qn /norestart'
        arguments       = @{
            ACCEPTEULA                     = 'yes'
            ACCEPT_THIRDPARTY_LICENSES     = '1'
            INSTALLDIR                     = ''
            VBREM_LICENSE_FILE             = ''
            VBREM_SERVICE_USER             = ''
            VBREM_SERVICE_PASSWORD         = ''
            VBREM_SERVICE_PORT             = ''
            VBREM_SQLSERVER_SERVER         = 'localhost\SQLEXPRESS'
            VBREM_SQLSERVER_DATABASE       = ''
            VBREM_SQLSERVER_AUTHENTICATION = ''
            VBREM_SQLSERVER_USERNAME       = ''
            VBREM_SQLSERVER_PASSWORD       = ''
            VBREM_TCPPORT                  = ''
            VBREM_SSLPORT                  = ''
            VBREM_THUMBPRINT               = ''
            VBREM_RESTAPISVC_PORT          = ''
            VBREM_RESTAPISVC_SSLPORT       = ''
            VBREM_CONFIG_SCHANNEL          = ''
            VBR_CHECK_UPDATES              = '0'
        }
    }
    localFiles    = @()
    remoteFiles   = @()
    manifest      = @{
        metadata = @{
            id                       = 'veeam-enterprise'
            title                    = 'Veeam Backup Enterprise Manager'
            version                  = '11.0.0.837'
            authors                  = 'Veeam'
            owners                   = 'Joshua Gilman'
            summary                  = 'Installs Veeam Backup Enterprise Manager'
            description              = 'Veeam Backup & Replication is a backup solution developed for VMware vSphere and Microsoft Hyper-V virtual environments. Veeam Backup & Replication provides a set of features for performing data protection and disaster recovery tasks.'
            projectUrl               = 'http://www.veeam.com/'
            packageSourceUrl         = 'https://github.com/jmgilman/ChocolateyPackageManager'
            tags                     = 'veeam backup replication catalog'
            copyright                = '2021 Veeam'
            licenseUrl               = 'https://www.veeam.com/eula.html'
            requireLicenseAcceptance = 'false'
            dependencies             = @(
                @{
                    id      = 'veeam-iso'
                    version = '[11.0.0.837]'
                },
                @{
                    id      = 'veeam-catalog'
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