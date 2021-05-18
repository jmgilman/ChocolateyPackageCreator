@{
    name        = '7zip'
    shim        = $True
    remoteFiles = @(
        @{
            url        = 'https://www.7-zip.org/a/7z1900-x64.exe'
            sha1       = '9FA11A63B43F83980E0B48DC9BA2CB59D545A4E8'
            importPath = 'tools/7z.exe'
        }
    )
    manifest    = @{
        metadata = @{
            id                       = '7zip'
            title                    = '7Zip File Archiver'
            version                  = '19.00'
            authors                  = 'Igor Pavlov'
            owners                   = 'Joshua Gilman'
            summary                  = 'Installs 7Zip CLI tool'
            description              = '7-Zip is a file archiver with a high compression ratio.'
            projectUrl               = 'https://www.7-zip.org/'
            packageSourceUrl         = 'https://github.com/jmgilman/ChocolateyPackageManager'
            tags                     = '7zip file archive'
            copyright                = '2021 Igor Pavlov'
            licenseUrl               = 'http://www.7-zip.org/license.txt'
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