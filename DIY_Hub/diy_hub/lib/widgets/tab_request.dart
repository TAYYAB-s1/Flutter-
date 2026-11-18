// lib/services/tab_request.dart
// A tiny bridge that lets a pushed screen ask the Home shell to show a
// particular bottom-nav tab. A screen calls TabRequest.go(index) and then
// pops back to the first route; HomeScreen listens and switches the tab.
//   0 = Home, 1 = Labs, 2 = Stats, 3 = Saved, 4 = Config

import 'package:flutter/foundation.dart';

class TabRequest {
  TabRequest._();

  static final ValueNotifier<int?> notifier = ValueNotifier<int?>(null);

  static void go(int index) => notifier.value = index;
}
