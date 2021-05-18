@{
    name        = 'ms-reportviewer2015'
    installer   = @{
        scriptPath    = 'tools'
        installerPath = 'tools/ReportViewer.msi'
        installerType = 'msi'
        exitCodes     = @(0, 3010, 1603, 1641)
        flags         = '/qn /norestart'
    }
    remoteFiles = @(
        @{
            url        = 'https://download.microsoft.com/download/A/1/2/A129F694-233C-4C7C-860F-F73139CF2E01/ENU/x86/ReportViewer.msi'
            sha1       = 'DDF94C52F2CBA110306916667EFD168DD260769D'
            importPath = 'tools/ReportViewer.msi'
        }
    )
    manifest    = @{
        metadata = @{
            id                       = 'ms-reportviewer2015'
            title                    = 'Microsoft Report Viewer 2015 Runtime'
            version                  = '12.0.2402.15'
            authors                  = 'Microsoft'
            owners                   = 'Joshua Gilman'
            summary                  = 'Installs Microsoft Report Viewer 2015 Runtime'
            description              = 'The Microsoft Report Viewer 2015 Runtime redistributable package, includes controls for viewing reports designed using Microsoft reporting technology.'
            projectUrl               = 'https://www.microsoft.com/en-us/download/details.aspx?id=45496'
            packageSourceUrl         = 'https://github.com/jmgilman/ChocolateyPackageManager'
            tags                     = 'microsoft report viewer 2015 runtime'
            copyright                = '2021 Microsoft'
            licenseUrl               = 'https://www.microsoft.com/en-us/download/details.aspx?id=45496'
            requireLicenseAcceptance = 'false'
            dependencies             = @(
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