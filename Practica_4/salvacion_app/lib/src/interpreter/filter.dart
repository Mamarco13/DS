import 'filter_message.dart';

abstract class Filter {
  void execute(FilterMessage message);
}
