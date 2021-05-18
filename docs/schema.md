# Package File Schema

Below is the schema for the various parts of the package file. Note that
properties which are required and are not present in your final configuration
file will result in the module failing the validation step. Any optional
properties that are not defined in your configuration file will automatically
have the default value from the schema applied to them.

See the [schema directory](ChocolateyPackageCreator/schema) for all of the schema files.


## [ChocolateyPackage](ChocolateyPackageCreator/schema/ChocolateyPackage.psd1)
| Name | Type | Required | Default Value | Description
| --- | --- | --- | --- | --- |
| Name | String | True | | The name of the package (used to identify it in logging)
| ProcessScript | String | False | `''` | The relative path a script to use for processing package files
| Shim | Boolean | False | False | Whether or not to shim exe files found in the package files
| Installer | [PackageInstaller](#PackageInstaller) | False | `@{}` | Configuration data for automatically generated a `ChocolateyInstall.ps` file
| LocalFiles | [LocalFile[]](#LocalFile) | False | `@()` | A list of local files to be copied to the package
| RemoteFiles | [RemoteFile[]](#RemoteFile) | False | `@()` | A list of remote files to be downloaded to the package
| Manifest | [PackageManifest](#PackageManifest) | True | | Configuration data for generating the package manifest file

## [ChocolateyISOPackage](ChocolateyPackageCreator/schema/ChocolateyISOPackage.psd1)
| Name | Type | Required | Default Value | Description
| --- | --- | --- | --- | --- |
| Name | String | True | | The name of the package (used to identify it in logging)
| IsoFile | [RemoteFile](#RemoteFile) | True | | The remote file describing where the ISO file is to be downloaded from
| Manifest | [PackageManifest](#PackageManifest) | True | | Configuration data for generating the package manifest file for the ISO file package
| MetaPackage | [ChocolateyPackage](#ChocolateyPackage) | True | | The package object for the meta package which combines all other package files
| Packages | [ChocolateyPackage[]](#ChocolateyPackage) | True | | A list of all sub-packages that will be compiled as part of the final package

## [PackageInstaller](ChocolateyPackageCreator/schema/PackageInstaller.psd1)
| Name | Type | Required | Default Value | Description
| --- | --- | --- | --- | --- |
| ScriptPath | String | True | | The relative path where the generated installer script will be placed
| InstallerPath | String | True | | The relative path to the installer file (i.e. MSI file)
| InstallerPath64 | String | False | `''` | The relative path to the 64-bit version of the installer file
| InstallerType | String | True | | The installer file type (i.e. `msi` or `exe`)
| ExitCodes | Integer[] | False | `@(0)` | An array of valid exit codes for the installer
| Flags | String | False | `''` | A string of flags to pass to the installer
| ArgumentPrefix | String | False | `''` | A prefix to prepend to every argument passed to the installer
| Arguments | Hashtable | False | `@{}` | A hash table of arguments the end-user can supply which will be passed to the installer

## [LocalFile](ChocolateyPackageCreator/schema/LocalFile.psd1)
| Name | Type | Required | Default Value | Description
| --- | --- | --- | --- | --- |
| LocalPath | String | True | | The relative path (from the package configuration file) to a local file to include in the package
| ImportPath | String | True | | The relative path (from the package root) where the file should be copied

## [RemoteFile](ChocolateyPackageCreator/schema/RemoteFile.psd1)
| Name | Type | Required | Default Value | Description
| --- | --- | --- | --- | --- |
| Url | String | True | | The URL the file will be downloaded from
| Sha1 | String | False | `''` | The expected SHA1 hash of the remote file
| ImportPath | String | True | | The relative path (from the package root) where the file should be downloaded to

## [PackageManifest](ChocolateyPackageCreator/schema/PackageManifest.psd1)
| Name | Type | Required | Default Value | Description
| --- | --- | --- | --- | --- |
| Metadata | [PackageMetadata](#PackageMetadata) | True | | Configuration data for generating the package metadata
| Files | [PackageFile[]](#PackageFile) | False | `@()` | A list of relative package file or file paths to include in the final compiled package file

## [PackageMetadata](ChocolateyPackageCreator/schema/PackageMetadata.psd1)
| Name | Type | Required | Default Value | Description
| --- | --- | --- | --- | --- |
| Id | String | True | | The unique id of the package
| Title | String | True | | The title of the package
| Version | String | True | | The version of the package
| Authors | String | True | | The original authors of the packaged software
| Owners | String | True | | The maintainers of the package
| Summary | String | True | | A brief summary of the packaged software
| Description | String | True | | A longer description of the packaged software
| ProjectUrl | String | True | | The URL to the project page of the packaged software
| PackageSourceUrl | String | True | | The URL to the source code of the package
| Tags | String | True | | A comma separated list of tags for identifying this package
| Copyright | String | True | | The copyright statement for the packaged software
| RequireLicenseAcceptance | String | True | | Whether the end-user is required to accept the software license before installing
| Dependencies | [PackageDependency[]](#PackageDependency) | False | `@()` | A list of packages this package is dependent on

## [PackageFile](ChocolateyPackageCreator/schema/PackageFile.psd1)
| Name | Type | Required | Default Value | Description
| --- | --- | --- | --- | --- |
| Src | String | True | | A relative package file or file path to include in the final compiled package file
| Target | String | True | | The relative package path where the source files will be placed in the final compiled package file

## [PackageDependency](ChocolateyPackageCreator/schema/PackageDependency.psd1)
| Name | Type | Required | Default Value | Description
| --- | --- | --- | --- | --- |
| Id | String | True | | The package ID of the dependent package
| Version | String | False | `''` | The required version of the dependent package