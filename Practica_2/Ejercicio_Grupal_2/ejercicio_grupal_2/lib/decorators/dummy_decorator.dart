import 'secret_keeper_decorator.dart';

class DummyDecorator extends SecretKeeperDecorator {
  DummyDecorator(super.wrappee);

  @override
  Future<String> ask(String userMessage) {
    // No hace nada (placeholder)
    return wrappee.ask(userMessage);
  }
}