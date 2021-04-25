# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[unreleased]: https://github.com/jmgilman/ChocolateyPackageCreator/compare/v0.0.4...HEAD
[0.0.4]: https://github.com/jmgilman/ChocolateyPackageCreator/compare/v0.0.3...v0.0.4
[0.0.3]: https://github.com/jmgilman/ChocolateyPackageCreator/compare/v0.0.2...v0.0.3
[0.0.2]: https://github.com/jmgilman/ChocolateyPackageCreator/compare/v0.0.1...v0.0.2
[0.0.1]: https://github.com/jmgilman/ChocolateyPackageCreator/releases/tag/v0.0.1