# padding_scrollbar

A scrollbar widget that supports padding.

### Usage

Add the package to your `pubspec.yaml`:
```yaml
dependencies:
  padding_scrollbar: ^0.0.4
```

Import the package:
```dart
import 'package:padding_scrollbar/padding_scrollbar.dart';
```

Use the widget:
```dart
PaddingScrollbar(
  padding: EdgeInsets.only(top: 56.0),
  child: ...,
)
```

Use the cupertino widget:
```dart
CupertinoPaddingScrollbar(
  padding: EdgeInsets.only(top: 56.0),
  child: ...,
)
```

That's it!

### Example

Example project can be found [here](https://github.com/xonaman/flutter-padding-scrollbar/tree/master/example).