@{
    name      = 'veeam-server'
    installer = @{
        scriptPath    = 'tools'
        installerPath = 'Backup\Server.x64.msi'
        installerType = 'msi'
        exitCodes     = @(0, 1638, 1641, 3010)
        flags         = '/qn /norestart'
        arguments     = @{
            ACCEPTEULA                   = 'yes'
            ACCEPT_THIRDPARTY_LICENSES   = '1'
            INSTALLDIR                   = ''
            VBR_LICENSE_FILE             = ''
            VBR_SERVICE_USER             = ''
            VBR_SERVICE_PASSWORD         = ''
            VBR_SERVICE_PORT             = ''
            VBR_SECURE_CONNECTIONS_PORT  = ''
            VBR_SQLSERVER_SERVER         = 'localhost\SQLEXPRESS'
            VBR_SQLSERVER_DATABASE       = ''
            VBR_SQLSERVER_AUTHENTICATION = ''
            VBR_SQLSERVER_USERNAME       = ''
            VBR_SQLSERVER_PASSWORD       = ''
            VBR_IRCACHE                  = ''
            VBR_CHECK_UPDATES            = '0'
            VBR_AUTO_UPGRADE             = '1'
        }
    }
    manifest  = @{
        metadata = @{
            id                       = 'veeam-server'
            title                    = 'Veeam Backup & Replication Server'
            version                  = '11.0.0.837'
            authors                  = 'Veeam'
            owners                   = 'Joshua Gilman'
            summary                  = 'Installs the Veeam Backup & Replication Server'
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
                @{
                    id      = 'vcredist'
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