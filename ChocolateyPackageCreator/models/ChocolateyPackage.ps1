class ChocolateyPackage {
    [string] $Name
    [string] $Path
    [string] $ProcessScript
    [bool] $Shim
    [PackageManifest] $Manifest
    [LocalFile[]] $LocalFiles
    [RemoteFile[]] $RemoteFiles
}

class LocalFile {
    [string] $LocalPath
    [string] $ImportPath
}

class RemoteFile {
    [string] $Url
    [string] $Sha1
    [string] $ImportPath
}

class PackageManifest {
    [PackageMetadata] $Metadata
    [PackageFile[]] $Files
}

class PackageMetadata {
    [string] $Id
    [string] $Title
    [string] $Version
    [string] $Authors
    [string] $Owners
    [string] $Summary
    [string] $Description
    [string] $ProjectUrl
    [string] $PackageSourceUrl
    [string] $Tags
    [string] $Copyright
    [string] $LicenseUrl
    [string] $RequireLicenseAcceptance
    [PackageDependency[]] $Dependencies
}

class PackageDependency {
    [string] $Id
    [string] $Version
}

class PackageFile {
    [string] $Src
    [string] $Target
}