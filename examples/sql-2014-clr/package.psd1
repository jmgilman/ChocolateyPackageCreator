@{
    name          = 'sql-2014-clr'
    processScript = ''
    shim          = $False
    installer     = @{
        scriptPath      = 'tools'
        installerPath   = 'tools/SQLSysClrTypesx86.msi'
        installerPath64 = 'tools/SQLSysClrTypesx64.msi'
        installerType   = 'msi'
        exitCodes       = @(0, 1641, 3010)
        flags           = '/qn /norestart'
        argumentPrefix  = ''
        arguments       = @{}
    }
    localFiles    = @()
    remoteFiles   = @(
        @{
            url        = 'https://download.microsoft.com/download/6/7/8/67858AF1-B1B3-48B1-87C4-4483503E71DC/ENU/x86/SQLSysClrTypes.msi'
            sha1       = '4175191DAFA15D582C2438DAAA9E1EE19D68AB63'
            importPath = 'tools/SQLSysClrTypesx86.msi'
        }
        @{
            url        = 'https://download.microsoft.com/download/6/7/8/67858AF1-B1B3-48B1-87C4-4483503E71DC/ENU/x64/SQLSysClrTypes.msi'
            sha1       = 'C7457913643083C0A1C27E637F8E9043B3E94E66'
            importPath = 'tools/SQLSysClrTypesx64.msi'
        }
    )
    manifest      = @{
        metadata = @{
            id                       = 'sql-2014-clr'
            title                    = 'Microsoft System CLR Types for SQL Server 2014'
            version                  = '12.2.5000.0'
            authors                  = 'Microsoft'
            owners                   = 'Joshua Gilman'
            summary                  = 'Installs System CLR Types for SQL Server 2014'
            description              = 'The SQL Server System CLR Types package contains the components implementing the new geometry, geography, and hierarchyid types in SQL Server 2014.'
            projectUrl               = 'https://www.microsoft.com/en-us/download/details.aspx?id=53164'
            packageSourceUrl         = 'https://github.com/jmgilman/ChocolateyPackageManager'
            tags                     = 'microsoft-system-clr-types-for-sql-server-2014 SQL SQL2014 .NET CLR'
            copyright                = '2021 Microsoft'
            licenseUrl               = 'https://www.microsoft.com/en-us/download/details.aspx?id=53164'
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