@{
    name        = 'dotnet-472'
    installer   = @{
        scriptPath    = 'tools'
        installerPath = 'tools/ndp472-kb4054530-x86-x64-allos-enu.exe'
        installerType = 'exe'
        exitCodes     = @(0, 3010)
        flags         = '/q /norestart'
    }
    remoteFiles = @(
        @{
            url        = 'https://download.visualstudio.microsoft.com/download/pr/887938c3-2a46-4069-a0b1-207035f1dd82/c8fe3fec22581fce77a5120c9d30828b/ndp472-kb4054530-x86-x64-allos-enu.exe'
            sha1       = 'CDAC2CCE64932CF8BDC57FEE18296E98B1967B16'
            importPath = 'tools/ndp472-kb4054530-x86-x64-allos-enu.exe'
        }
    )
    manifest    = @{
        metadata = @{
            id                       = 'dotnet-472'
            title                    = 'Microsoft .NET Framework 4.7.2'
            version                  = '4.7.2'
            authors                  = 'Microsoft'
            owners                   = 'Gilman Lab'
            summary                  = 'Installs Microsoft .NET Framework 4.7.2'
            description              = '.NET Framework is a Windows-only version of .NET for building any type of app that runs on Windows.'
            projectUrl               = 'https://dotnet.microsoft.com/'
            packageSourceUrl         = 'https://github.com/jmgilman/ChocolateyPackageManager'
            tags                     = 'microsoft dot net framework'
            copyright                = '2021 Microsoft'
            licenseUrl               = 'https://dotnet.microsoft.com/platform/free'
            requireLicenseAcceptance = 'false'
        }
        files    = @(
            @{
                src    = 'tools\**'
                target = 'tools'
            }
        )
    }
}