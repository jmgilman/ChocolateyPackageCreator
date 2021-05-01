@{
    name          = 'vcredist'
    processScript = ''
    shim          = $True
    installer     = @{
        scriptPath      = 'tools'
        installerPath   = 'tools/VC_redist.x86.exe'
        installerPath64 = 'tools/VC_redist.x64.exe'
        installerType   = 'exe'
        flags           = '/quiet /norestart'
        arguments       = @{}
    }
    localFiles    = @()
    remoteFiles   = @(
        @{
            url        = 'https://download.visualstudio.microsoft.com/download/pr/85d47aa9-69ae-4162-8300-e6b7e4bf3cf3/52B196BBE9016488C735E7B41805B651261FFA5D7AA86EB6A1D0095BE83687B2/VC_redist.x64.exe'
            sha1       = 'A4EFAD335D3CCFA19963F53398E87BE5C8BEBC45'
            importPath = 'tools/VC_redist.x64.exe'
        }
        @{
            url        = 'https://download.visualstudio.microsoft.com/download/pr/85d47aa9-69ae-4162-8300-e6b7e4bf3cf3/14563755AC24A874241935EF2C22C5FCE973ACB001F99E524145113B2DC638C1/VC_redist.x86.exe'
            sha1       = 'D848A57ADB68456B91BD8BA5108C116DE8DA8F25'
            importPath = 'tools/VC_redist.x86.exe'
        }
    )
    manifest      = @{
        metadata = @{
            id                       = 'vcredist'
            title                    = 'Microsoft Visual C++ Redistributable'
            version                  = '14.28.29914'
            authors                  = 'Microsoft'
            owners                   = 'Joshua Gilman'
            summary                  = 'Installs Microsoft Visual C++ Redistributable'
            description              = 'Run-time components that are required to run C++ applications that are built by using Visual Studio 2015-2019'
            projectUrl               = 'https://visualstudio.microsoft.com/vs/'
            packageSourceUrl         = 'https://github.com/jmgilman/ChocolateyPackageManager'
            tags                     = 'microsoft visual c++ redistributable 140 2015 2017 2019'
            copyright                = '2021 Microsoft'
            licenseUrl               = 'https://visualstudio.microsoft.com/license-terms/mlt031619/'
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