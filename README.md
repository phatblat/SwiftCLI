# SwiftCLI

A template for Swift projects using the Swift Package Manager. Includes 3 targets:

- `swiftcli`: an executable
- `SwiftCLIKit`: a library/framework to hold all logic
- `SwiftCLIKitTests`: tests for the library

The reason for putting all logic in the library is because an executable target
is not a bundle and thus Xcode can't run tests against it.

`Makefile` is based on Rob Allen's
[Cross-platform Makefile for Swift](https://akrabat.com/cross-platform-makefile-for-swift/)

## 📄 License

This repo is licensed under the MIT License. See the [LICENSE](LICENSE.md) file for rights and limitations.
