import 'secret_keeper_decorator.dart';

class LengthLimitDecorator extends SecretKeeperDecorator {
  LengthLimitDecorator(super.wrappee);

  static const int maxLength = 200;

  @override
  Future<String> ask(String userMessage) async {
    final response = await wrappee.ask(userMessage);

    if (response.length <= maxLength) return response;

    return response.substring(0, maxLength);
  }
}