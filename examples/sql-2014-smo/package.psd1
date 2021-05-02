@{
    name          = 'sql-2014-smo'
    processScript = ''
    shim          = $False
    installer     = @{
        scriptPath      = 'tools'
        installerPath   = 'tools/SharedManagementObjectsx86.msi'
        installerPath64 = 'tools/SharedManagementObjectsx64.msi'
        installerType   = 'msi'
        exitCodes       = @(0, 1641, 3010)
        flags           = '/qn /norestart'
        arguments       = @{}
    }
    localFiles    = @()
    remoteFiles   = @(
        @{
            url        = 'https://download.microsoft.com/download/6/7/8/67858AF1-B1B3-48B1-87C4-4483503E71DC/ENU/x86/SharedManagementObjects.msi'
            sha1       = 'C07B882538863A2B125A2EDA29D269D803CD0F0D'
            importPath = 'tools/SharedManagementObjectsx86.msi'
        }
        @{
            url        = 'https://download.microsoft.com/download/6/7/8/67858AF1-B1B3-48B1-87C4-4483503E71DC/ENU/x64/SharedManagementObjects.msi'
            sha1       = '2754C510EB14CCABF5E57E784A7E69B845531B5B'
            importPath = 'tools/SharedManagementObjectsx64.msi'
        }
    )
    manifest      = @{
        metadata = @{
            id                       = 'sql-2014-smo'
            title                    = 'Microsoft SQL Server 2014 Management Objects'
            version                  = '12.2.5000.0'
            authors                  = 'Microsoft'
            owners                   = 'Joshua Gilman'
            summary                  = 'Installs Microsoft SQL Server 2014 Management Objects'
            description              = 'The SQL Server Management Objects (SMO) is a .NET Framework object model that enables software developers to create client-side applications to manage and administer SQL Server objects and services.'
            projectUrl               = 'https://www.microsoft.com/en-us/download/details.aspx?id=53164'
            packageSourceUrl         = 'https://github.com/jmgilman/ChocolateyPackageManager'
            tags                     = 'microsoft-sql-server-2014-management-objects SQL SQL2014 SMO .NET XML CLR'
            copyright                = '2021 Microsoft'
            licenseUrl               = 'https://docs.microsoft.com/en-us/sql/relational-databases/server-management-objects-smo/smo-license-terms?view=sql-server-2014'
            requireLicenseAcceptance = 'false'
            dependencies             = @(
                @{
                    id      = 'sql-2014-clr'
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