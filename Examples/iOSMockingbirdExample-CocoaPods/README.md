# Mockingbird CocoaPods Example

A minimal example of [Mockingbird](https://github.com/birdrides/mockingbird) integrated into an Xcode project using
CocoaPods.

Having issues setting up Mockingbird? Join the [Slack channel](https://slofile.com/slack/birdopensource) or
[file an issue](https://github.com/birdrides/mockingbird/issues/new/choose).

## Tutorial

### Create the Xcode Project

Open Xcode and create an iOS Single View App with the name `iOSMockingbirdExample-CocoaPods`. Make sure
that the checkbox labeled “Include Unit Tests” is selected.

### Configure CocoaPods

Create the Podfile in the Xcode project root directory.

```bash
$ cd iOSMockingbirdExample-CocoaPods
$ touch Podfile
```

Add Mockingbird as a dependency to the test target in the Podfile.

```ruby
target 'iOSMockingbirdExample-CocoaPodsTests' do
  use_frameworks!
  pod 'MockingbirdFramework', '~> 0.11.0'
end
```

### Install Mockingbird

Install the framework and CLI.

```bash
$ pod install
$ cd Pods/MockingbirdFramework
$ make install-prebuilt
```

Then configure the test target by using the CLI.

```bash
$ mockingbird install \
  --target iOSMockingbirdExample-CocoaPodsTests \
  --source iOSMockingbirdExample-CocoaPods
```

Finally, download the starter supporting source files into your project root.

```bash
$ curl -Lo \
  'MockingbirdSupport.zip' \
  'https://github.com/birdrides/mockingbird/releases/download/0.11.0/MockingbirdSupport.zip'
$ unzip -o 'MockingbirdSupport.zip'
$ rm -f 'MockingbirdSupport.zip'
```

### Run Tests

Open the Xcode workspace generated by CocoaPods.

```bash
$ open iOSMockingbirdExample-CocoaPods.xcworkspace
```

Take a peek at the example test and sources and then run the tests (⌘+U).:

- [`TreeTests.swift`](iOSMockingbirdExample-CocoaPodsTests/TreeTests.swift)
- [`Tree.swift`](iOSMockingbirdExample-CocoaPods/Tree.swift)
- [`Bird.swift`](iOSMockingbirdExample-CocoaPods/Bird.swift)

Bonus: look at the contents of 
[`.mockingbird-ignore`](iOSMockingbirdExample-CocoaPodsTests/.mockingbird-ignore). 