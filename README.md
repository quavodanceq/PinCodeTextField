# PinCodeTextField

A customizable code textField. Can be used for phone verification codes, passwords etc.

![example](https://github.com/quavodanceq/PinCodeTextField/assets/80914126/2840d3b7-135e-4a7e-81d4-8aaf89996ebf)

## Installation

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler. 

```swift
dependencies: [
    .package(url: "github.com/quavodanceq/PinCodeTextField.git", .branch(main))
]
```

## Usage

1. Interface Builder:

Add a `UITextField` in your *Interface Builder* and change the class of a textField from `UITextField` to `PinCodeTextField`. You can set the properties in the *Attributes Inspector* and see a live preview

<img width="304" alt="usage" src="https://github.com/quavodanceq/PinCodeTextField/assets/80914126/81ff425b-a4d9-4742-b70e-1cfeabc60aec">

2. Programmatically:

```swift
let textField = PinCodeTextField()
textField.emptyDigitBorderColor = .gray
textField.filledDigitBorderColor = .blue
textField.digitsCount = 4
textField.bordersSpacing = 5
```
