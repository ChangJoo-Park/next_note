import 'package:next_page/core/base/base_view_model.dart';

class MarkdownViewModel extends BaseViewModel {
  String _content = '';
  MarkdownViewModel();

  // Add ViewModel specific code here
  String get content => _content;
  set content(String value) {
    _content = value;
    notifyListeners();
  }
}
