@{
    name          = 'sql-express-adv'
    processScript = 'process.ps1'
    shim          = $False
    installer     = @{}
    localFiles    = @(
        @{
            localPath  = 'files/config.eps'
            importPath = 'tools/config.eps'
        }
        @{
            localPath  = 'files/ChocolateyInstall.ps1'
            importPath = 'tools/ChocolateyInstall.ps1'
        }
    )
    remoteFiles   = @(
        @{
            url        = 'https://download.microsoft.com/download/8/4/c/84c6c430-e0f5-476d-bf43-eaaa222a72e0/SQLEXPRADV_x64_ENU.exe'
            sha1       = 'C70158B4A53960D3029B9688D781F166FA8BC637'
            importPath = 'tools/SQLEXPRADV_x64_ENU.exe'
        }
    )
    manifest      = @{
        metadata = @{
            id                       = 'sql-express-adv'
            title                    = 'Microsoft SQL Server Express 2019 with Advanced Services'
            version                  = '15.0.2000.5'
            authors                  = 'Microsoft'
            owners                   = 'Joshua Gilman'
            summary                  = 'Installs SQL Server 2019 Express database engine'
            description              = 'Experience the full feature set of SQL Server Express. This package contains the Database Engine, Reporting Services, and Full Text Search features.'
            projectUrl               = 'https://www.microsoft.com/en-us/server-cloud/products/sql-server-editions/sql-server-express.aspx'
            packageSourceUrl         = 'https://github.com/jmgilman/ChocolateyPackageCreator'
            tags                     = 'sql server express 2019'
            copyright                = '2021 Microsoft'
            licenseUrl               = 'https://download.microsoft.com/download/6/6/0/66078040-86d8-4f6e-b0c5-e9919bbcb537/SQL%20Server%202019%20Licensing%20guide.pdf'
            requireLicenseAcceptance = 'false'
            dependencies             = @(
                @{
                    id      = 'eps.extension'
                    version = '1.0.0'
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