# Mockingbird

[![Swift Package Manager](https://img.shields.io/badge/swift%20package%20manager-compatible-brightgreen.svg)](https://swift.org/package-manager/)

Mockingbird is a convenient mocking framework for Swift.

```swift
let bird = BirdMock()
given(bird.chirp(volume: any())) ~> true
PalmTree(containing: bird).shake()
verify(bird.chirp(volume: 50)).wasCalled()
```
---

## Installation

### Carthage

Add Mockingbird to your `Cartfile`.

```
github "birdrides/mockingbird" ~> 0.0.1
```

Then download and install the latest `Mockingbird.pkg` from [Releases](https://github.com/birdrides/mockingbird/releases).

### CocoaPods

CocoaPods support coming soon™

### Swift Package Manager

Add Mockingbird as a dependency in your `Package.swift` file.

```swift
dependencies: [
  .package(url: "https://github.com/birdrides/mockingbird.git", .upToNextMajor(from: "0.0.1"))
]
```

Then download and install the latest `Mockingbird.pkg` from [Releases](https://github.com/birdrides/mockingbird/releases).

### From Source

```bash
git clone https://github.com/birdrides/mockingbird.git
cd mockingbird
make install
```

## Setup

Mockingbird generates mocks using the `mockingbird` command line tool which can be integrated into your
build process in many different ways.

### Easy Integration

Mockingbird CLI can automatically add a build step to generate mocks in the background whenever the specified 
targets are compiled.

```bash
mockingbird install --project <xcodeproj_path> --targets <comma_separated_targets>
```

### Manual Integration

If you use a project or workspace generator such as [XcodeGen](https://github.com/yonaskolb/XcodeGen) you 
may need to add a Run Script Phase to generate mocks. See [Mockingbird CLI - Generate](#generate) for all 
generator options. 

```bash
mockingbird generate &
``` 

## Mockingbird CLI

### Generate

Generate mocks for a set of targets in a project.

`mockingbird generate` 
* `--project <xcodeproj_path>` Path to the Xcode project file. Defaults to the `PROJECT_FILE_PATH` environment variable set during builds.
* `--srcroot <source_root_path>` Path to the directory containing the project’s source files. Defaults to the `SRCROOT` environment variable set during builds or to the parent directory of `<xcodeproj_path>`.
* `--targets <comma_separated_targets>` Comma-separated list of target names to mock. For better performance, batch mock generation by specifying multiple targets. Defaults to the `TARGET_NAME` environment variable set during builds.
* `--outputs <comma_separated_output_paths>` Comma-separated list of custom file paths to store generated mocks for each target. The number of `outputs` should match the number of `targets`. Defaults to `<src_root>/Mockingbird/Mocks/<target_name>Mocks.generated.swift`.
* `--preprocessor <preprocessor_expression>` Preprocessor expression to wrap all generated mocks in. For example, specifying `DEBUG` will add `#if DEBUG ... #endif` to every mock file. Defaults to not adding a preprocessor expression.
* `--disable-module-import` Whether `@testable import <target_name>` should be omitted from generated mocks. Add this flag if mocks are included in targets instead of in test targets. Consider specifying a `preprocessor` expression when using the `no-module-import` option.

### Install

Starts automatically calling `mockingbird generate` when building any of the provided targets. Adds a custom 
Run Script Phase to each target.

`mockingbird install`
* `--project <xcodeproj_path>` Path to the Xcode project file.
* `--srcroot <source_root_path>` Path to the directory containing the project’s source files. Defaults to the parent directory of `<xcodeproj_path>`.
* `--targets <comma_separated_targets>` Comma-separated list of target names that will start automatically generating mocks.
* `--outputs <comma_separated_output_paths>` Comma-separated list of custom file paths to store generated mocks for each target. The number of `outputs` should match the number of `targets`. Defaults to `<src_root>/Mockingbird/Mocks/<target_name>Mocks.generated.swift`.
* `--preprocessor` Preprocessor expression to wrap all generated mocks in. For example, specifying `DEBUG` will add `#if DEBUG ... #endif` to every mock file. Defaults to not adding a preprocessor expression.
* `--override` Whether to re-install the Run Script Phase for each target in `targets`.
* `--synchronous` Whether building each target waits until mock generation completes. Add this flag if mocks are included in targets instead of in test targets. See also the `disable-module-import` flag.

### Uninstall

Stops automatically calling `mockingbird generate` when building.

`mockingbird uninstall`
* `--project <xcodeproj_path>` Path to the Xcode project file.
* `--targets <comma_separated_targets>` Comma-separated list of target names that will stop automatically generating mocks.
