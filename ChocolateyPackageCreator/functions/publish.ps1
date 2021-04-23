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
.PARAMETER ChocolateyPath
    The path to the choco binary - defaults to 'choco'
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
        [string] $ChocolateyPath = 'choco',
        [string[]] $ExtraArguments = @(),
        [switch] $Force
    )

    Write-Verbose ('Pushing Chocolatey package at {0}...' -f $PackageFile)
    $chocoArgs = [System.Collections.ArrayList]@(
        'push',
        $PackageFile,
        ('--source "{0}"' -f $Repository),
        ('--api-key "{0}"' -f $ApiKey)
    )

    if ($Force) {
        $chocoArgs.Add('--force') | Out-Null
    }

    if ($ExtraArguments) {
        $chocoArgs += $ExtraArguments
    }
    
    # Don't print out sensitive information
    $logStr = "Executing `"{0} {1}`"" -f $ChocolateyPath, ($chocoArgs -join ' ')
    Write-Verbose ($logStr -replace $ApiKey, '<REDACTED>')

    $proc = Start-Process $ChocolateyPath -ArgumentList $chocoArgs -PassThru -NoNewWindow -Wait
    $proc.ExitCode
}