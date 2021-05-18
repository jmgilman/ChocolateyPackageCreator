# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- Refactors the validation logic to use schema files
- Package files only need to declare required properties now instead of every property

## [0.1.1] - 2021-05-05

### Added
- Additional logging to generated installation scripts
- Support for defining the argument prefix in installation scripts

## [0.1.0] - 2021-05-04

### Added
- Adds `Installer` property to configuration file for dynamically creating the ChocolateyInstall.ps1 file
- Adds `New-ChocolateyISOPackage` and `Build-ChocolateyISOPackage` for building multiple packages against a single ISO
- Adds `Tool` parameter to `Publish-ChocolateyPackage` to support pushing via the NuGet CLI tool
- Updates Chrome example to use new `Installer` property
- Adds Veeam example demonstrating creation of a ChocolateyISOPackage
- Adds getting started guide and supporting documentation for the ISO package format

## [0.0.6] - 2021-04-29

### Added
- Adds force flag to cleanup operation

## [0.0.5] - 2021-04-27

### Fixed
- Fixes bug where an empty process script has its path qualified

## [0.0.4] - 2021-04-24

### Added
- Adds an example for packaging the Powershell EPS extension
- Adds an example for packaging SQL Server Express 2019 (Advanced)

### Changed
- Process scripts now receive two parameters, the build path and a copy of the ChocolateyPackage object
- Updates Chrome example to use new process script parameter
- Moves unshimming process to execute after the process script is executed
- README improvements

### Removed
- Removes example for packaging this repository as an extension

## [0.0.3] - 2021-04-24

### Changed
- Moved the `dependencies` property to its correct place under `metadata`
- Updated the NuSpec generation logic to be more dynamic
- Improves verbose logging

## [0.0.2] - 2021-04-24

### Added
- Example Azure DevOps pipeline file for Chrome example

### Changed
- Updated Github repository URL to be correct

## [0.0.1] - 2021-04-24

### Added
- Initial release

[unreleased]: https://github.com/jmgilman/ChocolateyPackageCreator/compare/v0.1.1...HEAD
[0.1.1]: https://github.com/jmgilman/ChocolateyPackageCreator/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/jmgilman/ChocolateyPackageCreator/compare/v0.0.6...v0.1.0
[0.0.6]: https://github.com/jmgilman/ChocolateyPackageCreator/compare/v0.0.5...v0.0.6
[0.0.5]: https://github.com/jmgilman/ChocolateyPackageCreator/compare/v0.0.4...v0.0.5
[0.0.4]: https://github.com/jmgilman/ChocolateyPackageCreator/compare/v0.0.3...v0.0.4
[0.0.3]: https://github.com/jmgilman/ChocolateyPackageCreator/compare/v0.0.2...v0.0.3
[0.0.2]: https://github.com/jmgilman/ChocolateyPackageCreator/compare/v0.0.1...v0.0.2
[0.0.1]: https://github.com/jmgilman/ChocolateyPackageCreator/releases/tag/v0.0.1