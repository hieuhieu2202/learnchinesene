import 'package:flutter/widgets.dart';

typedef NavigationCallback = void Function();

void navigateAfterFrame(NavigationCallback action) {
  WidgetsBinding.instance.addPostFrameCallback((_) => action());
}
