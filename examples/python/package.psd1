@{
    name          = 'python'
    processScript = ''
    shim          = $False
    installer     = @{
        scriptPath      = 'tools'
        installerPath   = 'tools\python-3.9.5.exe'
        installerPath64 = 'tools\python-3.9.5-amd64.exe'
        installerType   = 'exe'
        exitCodes       = @(0)
        flags           = '/quiet'
        argumentPrefix  = ''
        arguments       = @{
            InstallAllUsers           = '1'
            TargetDir                 = ''
            DefaultAllUsersTargetDir  = ''
            DefaultJustForMeTargetDir = ''
            DefaultCustomTargetDir    = ''
            AssociateFiles            = ''
            CompileAll                = ''
            PrependPath               = '1'
            Shortcuts                 = ''
            Include_doc               = ''
            Include_debug             = ''
            Include_dev               = ''
            Include_exe               = ''
            Include_launcher          = ''
            InstallLauncherAllUsers   = ''
            Include_lib               = ''
            Include_pip               = ''
            Include_symbols           = ''
            Include_tcltk             = ''
            Include_test              = ''
            Include_tools             = ''
            LauncherOnly              = ''
            SimpleInstall             = ''
            SimpleInstallDescription  = ''
        }
    }
    localFiles    = @()
    remoteFiles   = @(
        @{
            url        = 'https://www.python.org/ftp/python/3.9.5/python-3.9.5.exe'
            sha1       = '1A71DD77D9EF8C39AEB3AE218CD4F0353F8B3AFD'
            importPath = 'tools/python-3.9.5.exe'
        }
        @{
            url        = 'https://www.python.org/ftp/python/3.9.5/python-3.9.5-amd64.exe'
            sha1       = '248F7CE21FE350B308EFD5D13447ED4375696D4B'
            importPath = 'tools/python-3.9.5-amd64.exe'
        }
    )
    manifest      = @{
        metadata = @{
            id                       = 'python'
            title                    = 'Python 3'
            version                  = '3.9.5'
            authors                  = 'Python Software Foundation'
            owners                   = 'Joshua Gilman'
            summary                  = 'Installs Python 3'
            description              = 'Python is a programming language that lets you work quickly and integrate systems more effectively.'
            projectUrl               = 'https://www.python.org/'
            packageSourceUrl         = 'https://github.com/jmgilman/ChocolateyPackageManager'
            tags                     = 'python programming language'
            copyright                = '2021 Python Software Foundation'
            licenseUrl               = 'https://docs.python.org/3/license.html'
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