@{
    name          = 'veeam-catalog'
    processScript = ''
    shim          = $False
    installer     = @{
        scriptPath    = 'tools'
        installerPath = 'Catalog\VeeamBackupCatalog64.msi'
        installerType = 'msi'
        flags         = '/qn'
        arguments     = @{
            ACCEPT_THIRDPARTY_LICENSES = '1'
            INSTALLDIR                 = ''
            VM_CATALOGPATH             = ''
            VBRC_SERVICE_USER          = ''
            VBRC_SERVICE_PASSWORD      = ''
            VBRC_SERVICE_PORT          = ''
        }
    }
    localFiles    = @()
    remoteFiles   = @()
    manifest      = @{
        metadata = @{
            id                       = 'veeam-catalog'
            title                    = 'Veeam Backup & Replication Catalog'
            version                  = '11.0.0.837'
            authors                  = 'Veeam'
            owners                   = 'Joshua Gilman'
            summary                  = 'Installs the Veeam Backup & Replication Catalog service'
            description              = 'Veeam Backup & Replication is a backup solution developed for VMware vSphere and Microsoft Hyper-V virtual environments. Veeam Backup & Replication provides a set of features for performing data protection and disaster recovery tasks.'
            projectUrl               = 'http://www.veeam.com/'
            packageSourceUrl         = 'https://github.com/jmgilman/ChocolateyPackageManager'
            tags                     = 'veeam backup replication catalog'
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