import 'package:signals/signals.dart';

class HomeViewModel {
  final selectedIndex = signal<int>(0);

  void switchTab(int index) {
    selectedIndex.value = index;
  }
}
