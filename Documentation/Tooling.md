# Tooling

## Code Formatting

The following package is formatted using [swift-format](http://github.com/swiftlang/swift-format) to ensure a consistent style.

To make format changes, run the formatter using the following command:

```bash
swift format --in-place --parallel --recursive .
```

Please see the [`swift-format` repository](https://github.com/swiftlang/swift-format) for
additional details.

## `git`

### Ignore

```bash
git -c "core.ignorecase=false" check-ignore --verbose --no-index **/*
```

### Attributes

```bash
git check-attr --all -- Vendors
```
