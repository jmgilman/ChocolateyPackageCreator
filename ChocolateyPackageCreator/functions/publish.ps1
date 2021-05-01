<#
.SYNOPSIS
    Publishes the given Chocolatey package to the given NuGet repository
.DESCRIPTION
    Using the given API key, connects to and publishes the given Chocolatey 
    package to the given NuGet repository. This function will fail if the API 
    key has insufficient permissions on the repository.
.PARAMETER Repository
    The url of the NuGet repository to push to
.PARAMETER ApiKey
    A NuGet API key with sufficient privileges to publish the package
.PARAMETER PackageFile
    The path to the Chocolatey package file
.PARAMETER Tool
    The tool to use to perform the publish: Chocolatey or NuGet
.PARAMETER ChocolateyPath
    The path to the choco binary - defaults to 'choco'
.PARAMETER NuGetPath
    The path to the NuGet binary - defaults to 'nuget'
.PARAMETER ExtraArguments
    Additional arguments to pass to the choco binary during the push process
.PARAMETER Force
    Whether to force the push using the --force flag
.EXAMPLE
    Publish-ChocolateyPackage `
        -Repository nuget.my.com `
        -ApiKey 'myapikey' `
        -PackageFile 'path/to/package.nupkg'
        -Force
.OUTPUTS
    The exit code of the choco push process
#>
Function Publish-ChocolateyPackage {
    [cmdletbinding()]
    param(
        [Parameter(
            Mandatory = $true,
            Position = 1
        )]
        [string] $Repository,
        [Parameter(
            Mandatory = $true,
            Position = 2
        )]
        [string] $ApiKey,
        [Parameter(
            Mandatory = $true,
            Position = 3
        )]
        [string] $PackageFile,
        [ValidateSet('Chocolatey', 'NuGet')]
        [string] $Tool = 'Chocolatey',
        [string] $ChocolateyPath = 'choco',
        [string] $NuGetPath = 'nuget',
        [string[]] $ExtraArguments = @(),
        [switch] $Force
    )

    Write-Verbose ('Pushing Chocolatey package at {0}...' -f $PackageFile)
    switch ($Tool) {
        Chocolatey {
            $toolPath = $ChocolateyPath
            $toolArgs = [System.Collections.ArrayList]@(
                'push',
                $PackageFile,
                ('--source "{0}"' -f $Repository),
                ('--api-key "{0}"' -f $ApiKey)
            )

            if ($Force) {
                $toolArgs.Add('--force') | Out-Null
            }
        }
        NuGet {
            $toolPath = $NuGetPath
            $toolArgs = [System.Collections.ArrayList]@(
                'push',
                $PackageFile,
                ('-source "{0}"' -f $Repository),
                ('-apikey "{0}"' -f $ApiKey)
            )
        }
    }

    if ($ExtraArguments) {
        $toolArgs += $ExtraArguments
    }

    # Don't print out sensitive information
    $logStr = "Executing `"{0} {1}`"" -f $toolPath, ($toolArgs -join ' ')
    Write-Verbose ($logStr -replace $ApiKey, '<REDACTED>')

    $proc = Start-Process $toolPath -ArgumentList $toolArgs -PassThru -NoNewWindow -Wait
    $proc.ExitCode
}