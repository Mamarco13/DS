import 'filter.dart';
import 'filter_message.dart';

class FilterChain {
  final List<Filter> _filters = [];

  void addFilter(Filter filter) {
    _filters.add(filter);
  }

  void execute(FilterMessage message) {
    for (final filter in _filters) {
      filter.execute(message);
    }
  }
}
